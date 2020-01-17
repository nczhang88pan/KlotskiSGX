#include "Global.h"
#include "unSafeObject.h"
#include "DataAnalysis.h"
#include "Annotation.h"
#include "CallGraph.h"
#include "STaint.h"
#include "DeIRInstructionInsert.h"
#include "../../../../../lld/ELF/Config.h"

//debug
static unsigned VerboseLevel=3;

using namespace llvm;
#define DEBUG_TYPE "DeIRInstructionInsert"
bool supportBigObject=false;
#include "klotskiConfig.h"

#define insertValueToSlot(Build,srcValue,inlineGetVirtualAddress){\
    Value *CI_V=Build.CreateBitOrPointerCast(srcValue,Int64PtrTy);\
    if(CastInst *c1 = dyn_cast<CastInst>(CI_V)){\
        c1->setIsShadow(true);\
    }\
    CallInst *insertToTheFirstSlot=Build.CreateCall(inlineGetVirtualAddress,CI_V);\
    insertToTheFirstSlot->setTailCallKind(CallInst::TailCallKind::TCK_Tail);\
    insertToTheFirstSlot->setIsShadow(true);\
    }\

#define getVirtualAddress(Build,srcValue,destValueName)\
    Value *CI_V=Build.CreateBitOrPointerCast(srcValue,Int64PtrTy);\
    if(CastInst *c1 = dyn_cast<CastInst>(CI_V)){\
        c1->setIsShadow(true);\
    }\
    CallInst *reDereferencedStackAddress=Build.CreateCall(inlineGetVirtualAddress,CI_V);\
    reDereferencedStackAddress->setTailCallKind(CallInst::TailCallKind::TCK_Tail);\
    reDereferencedStackAddress->setIsShadow(true);\
    destValueName=Build.CreatePointerCast(reDereferencedStackAddress,srcValue->getType());\
    if(CastInst *c2 = dyn_cast<CastInst>(destValueName)){\
        c2->setIsShadow(true);\
    }\


#define _dereferenceAPointer(Build,srcValue,destValueName)                         \
    Value *destValueName;\
    Value *CI_1=Build.CreateBitOrPointerCast(srcValue,Int64PtrTy);\
    if(CastInst *c1 = dyn_cast<CastInst>(CI_1)){\
        c1->setIsShadow(true);\
    }\
    CallInst *dereferencedShadowValue=Build.CreateCall(inlineAddressDereference,CI_1);\
    dereferencedShadowValue->setTailCallKind(CallInst::TailCallKind::TCK_Tail);\
    dereferencedShadowValue->setIsShadow(true);\
    destValueName=Build.CreatePointerCast(dereferencedShadowValue,srcValue->getType());\
    if(CastInst *c2 = dyn_cast<CastInst>(destValueName)){\
        c2->setIsShadow(true);\
    }\

#define dereferenceAPointer(Build,srcValue,destValueName,Count)                         \
    Value *destValueName;\
    Value *CI_1=Build.CreateBitOrPointerCast(srcValue,Int64PtrTy);\
    if(CastInst *c1 = dyn_cast<CastInst>(CI_1)){\
        c1->setIsShadow(true);\
        Count++;\
    }\
    CallInst *dereferencedShadowValue=Build.CreateCall(inlineAddressDereference,CI_1);\
    dereferencedShadowValue->setTailCallKind(CallInst::TailCallKind::TCK_Tail);\
    dereferencedShadowValue->setIsShadow(true);\
    Count++;\
    destValueName=Build.CreatePointerCast(dereferencedShadowValue,srcValue->getType());\
    if(CastInst *c2 = dyn_cast<CastInst>(destValueName)){\
        c2->setIsShadow(true);\
        Count++;\
    }\

#define dereferenceAPointer_Control(Build,srcValue,destValueName,Count)                         \
    Value *destValueName;\
    Value *CI_1=Build.CreateBitOrPointerCast(srcValue,Int64PtrTy);\
    if(CastInst *c1 = dyn_cast<CastInst>(CI_1)){\
        c1->setIsShadow(true);\
        Count++;\
    }\
    CallInst *dereferencedShadowValue=Build.CreateCall(inlineAddressDereference_controlFlow,CI_1);\
    dereferencedShadowValue->setTailCallKind(CallInst::TailCallKind::TCK_Tail);\
    dereferencedShadowValue->setIsShadow(true);\
    Count++;\
    destValueName=Build.CreatePointerCast(dereferencedShadowValue,srcValue->getType());\
    if(CastInst *c2 = dyn_cast<CastInst>(destValueName)){\
        c2->setIsShadow(true);\
        Count++;\
    }\


static cl::opt<std::string> ClDIRIList("DIII", cl::desc("Dereference IR instruction insert"), cl::NotHidden);
static cl::opt<bool> ClDebug("DIIIDebug", cl::desc("debug"), cl::NotHidden,
                             cl::init(true));


bool DeIRInstructionInsert::verdictFromName(Function &F) {
    for(unsigned i=0;i<safeFunctions.size();i++){
        if(F.hasName() && F.getName().equals(safeFunctions[i])){
            noneRandomPointSet.push_back(&F);
            return true;
        }
    }
    if(F.getName().equals("put")){
        randomPointSet.push_back(&F);
        return true;
    }
    return false;
}


bool DeIRInstructionInsert::doInitialization(Module &M) {


    Int64PtrTy = Type::getInt64PtrTy(M.getContext());
    Int64Ty = Type::getInt64Ty(M.getContext());
    Int32PtrTy = Type::getInt32PtrTy(M.getContext());
    Int32Ty = Type::getInt32Ty(M.getContext());
    Int8Ty = Type::getInt8Ty(M.getContext());
    Int8PtrTy = Type::getInt8PtrTy(M.getContext());
    ShadowZero = M.getOrInsertGlobal("shadowNull",Type::getInt32Ty(M.getContext()));


    reDereference64 = dyn_cast<Function>(
            M.getOrInsertFunction("Redereference64",
            Type::getInt64PtrTy(M.getContext()),Int64PtrTy
            )
    );
    addressDereference64 = dyn_cast<Function>(
            M.getOrInsertFunction("addressDereference64",
            Type::getInt64PtrTy(M.getContext()),Int64PtrTy
            )
    );
    //inserted in front of memcpy memset memmove, it stores the logical value of the dest/src
    {

        reserveToSlot[0] = dyn_cast<Function>(
                M.getOrInsertFunction("reserveTo0Slot",
                                      Type::getVoidTy(M.getContext()),Int64PtrTy)
        );
        reserveToSlot[1] = dyn_cast<Function>(
                M.getOrInsertFunction("reserveTo1Slot",
                                      Type::getVoidTy(M.getContext()),Int64PtrTy)
        );
        inlineReserveToSlot[0] = InlineAsm::get(reserveToSlot[0]->getFunctionType(),
                                                "movq $0,0x20(%r15)",
                                                "r",true);
        inlineReserveToSlot[1] = InlineAsm::get(reserveToSlot[1]->getFunctionType(),
                                                "movq $0,0x28(%r15)",
                                                "r",true);
    }




    //rorx $$0xb,$1,%r14;
    //cmpb $$0x0,-0x3000(%r15d,%r14d,1);
    //jnz 1f
    //  pushq 1f
    //  jmp (%r15)
    //1:add (%r15d,%r14d,8),%r14;
    //rorx $$0x35,%r14,$0

    inlineAddressDereference = InlineAsm::get(addressDereference64->getFunctionType(),
                                              "movq $1,%r14;callq *0x60(%r15);movq %r14,$0",
                                              "=r,r,~{dirflag},~{fpsr},~{flags}",
                                              true);
//    inlineAddressDereference = InlineAsm::get(addressDereference64->getFunctionType(),
//                                              "movq $1,%r14;callq *0x60(%r15);movq %r14,$0",
//                                              "=r,X,~{dirflag},~{fpsr},~{flags}",
//                                              true);

    inlineAddressDereference_controlFlow = InlineAsm::get(addressDereference64->getFunctionType(),
                                                   "rorx $$0xb,$1,%r14;cmpb $$0x1,-0x3000(%r15d,%r14d,1);je 2f;push $$1f;jmpq *0x20(%r15);1:rorx $$0xb,$1,%r14;2:add (%r15d,%r14d,8),%r14;rorx $$0x35,%r14,$0",
                                                   "=r,r,~{dirflag},~{fpsr},~{flags}",
                                                   true);
    // shadowStackAddress = virtualStackAddress-(virtual2ShadowStackOffset)
    inlineGetVirtualAddress = InlineAsm::get(addressDereference64->getFunctionType(),
                                             "mov $1,$0;sub 0x50(%r15),$0",
                                             "=r,r,~{dirflag},~{fpsr},~{flags}",
                                             true);

    if(!reDereference64 || !addressDereference64){
        errs()<<"Cannot find atomic addressDereference funcs\n";
        exit(-1);
    }
    return false;
}

char DeIRInstructionInsert::ID = 0;

INITIALIZE_PASS_BEGIN(DeIRInstructionInsert, "DeIRInstrInsert-module",
                      "DIII : Dereference IR instruction insert.", false, true)
    INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
    INITIALIZE_PASS_DEPENDENCY(AAResultsWrapperPass)
    INITIALIZE_PASS_DEPENDENCY(BreakCriticalEdges)
    INITIALIZE_PASS_DEPENDENCY(LoopSimplify)
    INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
    INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass)
INITIALIZE_PASS_END(DeIRInstructionInsert, "DeIRInstrInsert-module",
                    "DIII : Dereference IR instruction insert.", false, true)


//we have disabled the support of the stack. So this part is no more useful.
int DeIRInstructionInsert::instrumentNormalAlloc(BasicBlock::iterator &I,BlockResult &BR) {
    AllocaInst *AI = dyn_cast<AllocaInst>(&*I);
    SmallVector<Instruction*,6> AIUserSet;
//    for(auto u:AI->users()){
//        AIUserSet.push_back(cast<Instruction>(u));
//    }
//    shadowMap[AI]=AI;
    localVarPointerUseTrack.insert(std::make_pair(AI,AI));
    //reDereference the real stack address into virtual stack address;
    //stackVritualAddress is the virutal stack address,AI is the real virtual address.
//    IRBuilder<> IRB(&*(std::next(I)));
    //getVirtualAddress(IRB,AI,stackVirtualAddress)

    //AI->print(errs());errs()<<"\n";
//    while (AIUserSet.size()){
//        Instruction *I=AIUserSet.pop_back_val();
//        if(GetElementPtrInst *gep = dyn_cast<GetElementPtrInst>(I)){
//        } else if(CastInst *ci = dyn_cast<CastInst>(I)){
//        } else if(StoreInst *si = dyn_cast<StoreInst>(I)){
//        } else if(LoadInst *LI = dyn_cast<LoadInst>(I)){
//        } else if (CallInst *CI = dyn_cast<CallInst>(I)){
//        } else if(PHINode *PHI=dyn_cast<PHINode>(I)){
////            Value *virtualStackAddress;
////            if(allocatePointers[AI]){
////                virtualStackAddress=allocatePointers[AI];
////            } else{
////                getVirtualAddress(IRB,AI,virtualStackAddress)
////                allocatePointers[AI]=virtualStackAddress;
////                BR.outShadow[virtualStackAddress]=AI;
////            }
////            for(int i=0;i<I->getNumOperands();i++){
////                if(I->getOperand(i)==&*I){
////                    PHI->setIncomingValue(i,virtualStackAddress);
////                    break;
////                }
////            }
//        } else if(SelectInst *SI = dyn_cast<SelectInst>(I)){
////            Value *value = SI->getCondition();
////            if(&*I == value) continue;
////            for(int i=1;i<=2;i++){
////                Value *temp = SI->getOperand(i);
////                if(temp == &*I){
////                    Value *virtualStack;
////                    if(allocatePointers[temp]){
////                        virtualStack = allocatePointers[temp];
////                    } else{
////                        getVirtualAddress(IRB,temp,virtualStack)
////                        allocatePointers[AI]=virtualStack;
////                        BR.outShadow[virtualStack]=AI;
////                    }
////                    SI->setOperand(i,virtualStack);
////                }
////
////            }
//
//        } else{
//            if(I->getType()->isPointerTy()){
//                I->print(errs());errs()<<__func__<<" do not hanle\n";
//                exit(-1);
//            }
//        }
//    }

    return 0;
}

int DeIRInstructionInsert::instrumentCast(BasicBlock::iterator &I,BlockResult &BR) {
    int skipCount=0;
    CastInst *CI = dyn_cast<CastInst>(&*I);
    IRBuilder<> IRB(&*(std::next(I)));
    if(CI->getOperand(0)->hasName()){
        if(CI->getOperand(0)->getName().startswith_lower("llvm.")) return 0;
    }

    if(PtrToIntInst *pti=dyn_cast<PtrToIntInst>(&*I)){
        Value *castSrc = pti->getOperand(0);
        if(localVarPointerUseTrack.find(castSrc)!=localVarPointerUseTrack.end()){
            Value *stackVirtualAddr;

            if(allocatePointers.find(castSrc)!=allocatePointers.end()){
                stackVirtualAddr=allocatePointers[castSrc];
            } else{
                Instruction *castSrcInstr = dyn_cast<Instruction>(castSrc);
                assert(castSrcInstr && "instrumentCast castSrc is not Instruction");
                IRBuilder<> IRBPRE(castSrcInstr->getIterator()->getNextNode());
                getVirtualAddress(IRBPRE,castSrc,stackVirtualAddr)
                allocatePointers.insert(std::make_pair(castSrc,stackVirtualAddr));
            }
            CI->setOperand(0,stackVirtualAddr);
        }
    }

    //assert(CI->getDestTy()->isArrayTy() && "we find casting into array");
    switch (CI->getType()->getTypeID()) {
        case Type::PointerTyID: {
            Value *castSrc = CI->getOperand(0);
            if(localVarPointerUseTrack.find(castSrc)!=localVarPointerUseTrack.end()){
                localVarPointerUseTrack.insert(std::make_pair(CI,castSrc));
            } else{
                Value *shadowSrc = getDereferenceValueOfAPointer(I, castSrc, BR, skipCount);
                Value *shadowCI = IRB.CreateCast(CI->getOpcode(), shadowSrc, CI->getType());
                if (CastInst *castInst = dyn_cast<CastInst>(shadowCI)) {
                    castInst->setIsShadow(true);
                    skipCount++;
                }
                BR.outShadow[CI] = shadowCI;
            }
            break;
        }
        case Type::ArrayTyID:{
            CI->print(errs());
            errs() << __func__ << "::find cast into Array\n";
            exit(-1);
        }
        default:{
//            errs() << __func__ << " find other casting\n";
//            I->print(errs());
//            errs() << "\n";
        }
    }

    return skipCount;
}
int DeIRInstructionInsert::instrumentLoad(BasicBlock::iterator &I,BlockResult &BR) {
    int skipCount=0;
    LoadInst *LI = dyn_cast<LoadInst>(&*I);
    Value* addressPointer = LI->getPointerOperand();
    IRBuilder<> IRB(&*(std::next(I)));
    MDNode* MD = I->getMetadata(MD_STATE);
    if(localVarPointerUseTrack.find(addressPointer)!=localVarPointerUseTrack.end()){

    } else{
        Value* shadowAddressPointer;
#if SUPPORT_BIG_OBJECT_TAINT
       if(supportBigObject && MD && !getStringFromMD(MD).compare("unsafe"))
#else
       if(supportBigObject)
#endif
       {
           shadowAddressPointer = getDereferenceValueOfAPointer_nonOptimization(I,addressPointer,BR,skipCount);
       }else{
           shadowAddressPointer = getDereferenceValueOfAPointer(I,addressPointer,BR,skipCount);
       }
        // shadowAddressPointer = getDereferenceValueOfAPointer(I,addressPointer,BR,skipCount);
        // Value* shadowAddressPointer = getDereferenceValueOfAPointer_nonOptimization(I,addressPointer,BR,skipCount);
        assert(shadowAddressPointer && "there is a pointer that has not been handled here");
        LI->setOperand(0,shadowAddressPointer);
    }

    return skipCount;
}

//dereference the target block/function's addresss
Value* DeIRInstructionInsert::getDereferenceValueOfAPointer_controlFlow(BasicBlock::iterator &I,Value *value, BlockResult &BR,int &count) {
    if (dyn_cast<ConstantPointerNull>(value)) {
        return value;
    } else if(localVarPointerUseTrack.find(value)!=localVarPointerUseTrack.end()){
        return value;
    }

    auto itr = BR.outShadow.find(value);
    if(itr!=BR.outShadow.end() && itr->second){
        return itr->second;
    }

    IRBuilder<> IRBPRE(&*I);
    if(isa<ConstantExpr>(value)) {
        if(GEPOperator *GEPO = dyn_cast<GEPOperator>(value)){
            Value *pointer = GEPO->getPointerOperand();

            auto temp = BR.outShadow.find(pointer);
            Value *shadowPointer ;

            if(temp==BR.outShadow.end()){
                dereferenceAPointer_Control(IRBPRE,pointer,shadow,count)
                shadowPointer = shadow;
                BR.outShadow[pointer]=shadow;
            }else{
                shadowPointer = temp->second;
            }
            SmallVector<Value *, 1> Idx;
            for (unsigned i = 1; i < GEPO->getNumOperands(); i++) {
                Idx.push_back(GEPO->getOperand(i));
            }

            Value *shadowValue = IRBPRE.CreateGEP(shadowPointer,Idx);
            dyn_cast<GetElementPtrInst>(shadowValue)->setIsShadow(true);
            return shadowValue;
        }else if(isa<ConstantPointerNull>(value)){
            return value;
        } else if(BitCastOperator *bco = dyn_cast<BitCastOperator>(value)){
            Value *pointer = bco->getOperand(0);
            auto temp = BR.outShadow.find(pointer);
            Value *shadowPointer ;
            if(temp==BR.outShadow.end()){
                dereferenceAPointer_Control(IRBPRE,pointer,shadow,count)
                shadowPointer = shadow;
                BR.outShadow[pointer]=shadow;
            } else{
                shadowPointer = temp->second;
            }
            Value *shadowInst = IRBPRE.CreateCast(
                    CastInst::getCastOpcode(value, false, bco->getDestTy(), false),
                    shadowPointer, bco->getDestTy());
            dyn_cast<CastInst>(shadowInst)->setIsShadow(true);
            //shadowMap[value] = shadowInst;
            return shadowInst;
        }else{
            IRBuilder<> IRBPRE(&*I);
            dereferenceAPointer_Control(IRBPRE,value,shadow,count)
            return shadow;
        }
    } else if(GlobalValue *GV = dyn_cast<GlobalValue>(value)){
        dereferenceAPointer_Control(IRBPRE,GV,dereferencedGlobalValue,count)
        BR.outShadow[value]=dereferencedGlobalValue;
        return dereferencedGlobalValue;
    } else{
        if(dyn_cast<InlineAsm>(value)){
            return value;
        } else if(Instruction *itp = dyn_cast<Instruction>(value)){
            dereferenceAPointer_Control(IRBPRE,itp,dereferencedPoint,count)
            BR.outShadow[value]=dereferencedPoint;
            return dereferencedPoint;
        }
        Function* F = I->getParent()->getParent();
        for (Function::arg_iterator AB=F->arg_begin(),AE=F->arg_end();AB!=AE;++AB) {
//            Value *arg=AB;
            if (AB->getType()->isPointerTy()) {
                if(AB==value){
                    dereferenceAPointer_Control(IRBPRE,value,shadowArg,count)
                    BR.outShadow[value]=shadowArg;
                    return shadowArg;
                }
            }
        }
        I->getParent()->getParent()->print(errs());
        I->print(errs());errs()<<"\n";
        value->print(errs());errs()<<"\n";
        value->getType()->print(errs());errs()<<"\n";
        errs()<<value->getType()->getTypeID()<<__func__<<"Value is not a constantPointer or global\n";
        exit(-1);
    }
}

Value* DeIRInstructionInsert::getDereferenceValueOfAPointer_nonOptimization(BasicBlock::iterator &I, Value *value,
                                                                            BlockResult &BR, int &count) {
    if (dyn_cast<ConstantPointerNull>(value)) {
        return value;
    } else if(localVarPointerUseTrack.find(value)!=localVarPointerUseTrack.end()){
        return value;
    }
    IRBuilder<> IRBPRE(&*I);
    dereferenceAPointer(IRBPRE,value,shadow,count)
    return shadow;

}
//dereferece a pointer, and return its shadow value as a result
Value* DeIRInstructionInsert::getDereferenceValueOfAPointer(BasicBlock::iterator &I,Value *value, BlockResult &BR,int &count) {

//    if(I->getOpcode()==Instruction::Load || I->getOpcode()==Instruction::Store){
//        //1. check whether this load/store is tagged (potentially access big data objects)
//        auto indexPair = unSafeOBjects.unSafePropagation.find(I->getFunction());
//        if(indexPair!=unSafeOBjects.unSafePropagation.end()){
//            auto tagSet = indexPair->second->find(&*I);
//            if(tagSet!=indexPair->second->end()){
//                //so this instruction is tagged, we should insert dereference instruction before it.
//                //we first get the dereferenced value from the shadow
//                auto itr = BR.outShadow.find(value);
//                IRBuilder<> IRBPRE(&*I);
//                if(itr==BR.outShadow.end()){
//                    dereferenceAPointer(IRBPRE,value,shadow,count)
//                    BR.outShadow[value] = shadow;
//                    return shadow;
//                }
//                //then we have found the shadow in outShadow,
//                //we check whether this shadow is an inline call, if not, we dereference it
//                if(CallInst *callInst = dyn_cast_or_null<CallInst>(itr->second)){
//                    assert(callInst->isInlineAsm() && " call inst is not inline");
//                    return itr->second;
//
//                }else if(PHINode *phi = dyn_cast_or_null<PHINode>(itr->second)){
//                    bool isAllSatisify = true;
//                    for(unsigned i=0;i<phi->getNumIncomingValues();i++){
//                        Value *value1 =phi->getIncomingValue(i);
//                        if(!dyn_cast_or_null<CallInst>(value1)){
//                            isAllSatisify = false;
//                        }
//                    }
//                    if(isAllSatisify){
//                        return itr->second;
//                    }
//                }
//                dereferenceAPointer(IRBPRE,value,shadow,count)
//                BR.outShadow[value] = shadow;
//                return shadow;
//            }
//        }
//    }

    if (dyn_cast<ConstantPointerNull>(value)) {
        return value;
    } else if(localVarPointerUseTrack.find(value)!=localVarPointerUseTrack.end()){
        return value;
    }

    auto itr = BR.outShadow.find(value);
    if(itr!=BR.outShadow.end() && itr->second){
        return itr->second;
    }

   IRBuilder<> IRBPRE(&*I);
    if(isa<ConstantExpr>(value)) {
        if(GEPOperator *GEPO = dyn_cast<GEPOperator>(value)){
            Value *pointer = GEPO->getPointerOperand();
            auto temp = BR.outShadow.find(pointer);
            Value *shadowPointer;

            if(temp == BR.outShadow.end()){
                dereferenceAPointer(IRBPRE,pointer,shadow,count)
                shadowPointer = shadow;
                BR.outShadow[pointer]=shadow;
            } else{
                shadowPointer = temp->second;
            }
            SmallVector<Value *, 1> Idx;
            for (unsigned i = 1; i < GEPO->getNumOperands(); i++) {
                Idx.push_back(GEPO->getOperand(i));
            }

            Value *shadowValue = IRBPRE.CreateGEP(shadowPointer,Idx);
            dyn_cast<GetElementPtrInst>(shadowValue)->setIsShadow(true);
            return shadowValue;
        }else if(isa<ConstantPointerNull>(value)){
            return value;
        } else if(BitCastOperator *bco = dyn_cast<BitCastOperator>(value)){
            Value *pointer = bco->getOperand(0);
            auto temp = BR.outShadow.find(pointer);
            Value *shadowPointer;
            if(temp==BR.outShadow.end()){
                dereferenceAPointer(IRBPRE,pointer,shadow,count)
                shadowPointer = shadow;
                BR.outShadow[pointer]=shadow;
            }else{
                shadowPointer= temp->second;
            }
            Value *shadowInst = IRBPRE.CreateCast(
                    CastInst::getCastOpcode(value, false, bco->getDestTy(), false),
                    shadowPointer, bco->getDestTy());
            dyn_cast<CastInst>(shadowInst)->setIsShadow(true);
            //shadowMap[value] = shadowInst;
            return shadowInst;
        }else{
            IRBuilder<> IRBPRE(&*I);
            dereferenceAPointer(IRBPRE,value,shadow,count)
            return shadow;
        }
    } else if(GlobalValue *GV = dyn_cast<GlobalValue>(value)){
        dereferenceAPointer(IRBPRE,GV,dereferencedGlobalValue,count)
        BR.outShadow[value]=dereferencedGlobalValue;
        return dereferencedGlobalValue;
    } else{
        if(dyn_cast<InlineAsm>(value)){
            return value;
        } else if(Instruction *itp = dyn_cast<Instruction>(value)){

            dereferenceAPointer(IRBPRE,itp,dereferencedPoint,count)
            BR.outShadow[value]=dereferencedPoint;
            return dereferencedPoint;
        }
        Function* F = I->getParent()->getParent();
        for (Function::arg_iterator AB=F->arg_begin(),AE=F->arg_end();AB!=AE;++AB) {
//            Value *arg=AB;
            if (AB->getType()->isPointerTy()) {
                if(AB==value){
                    dereferenceAPointer(IRBPRE,value,shadowArg,count)
                    BR.outShadow[value]=shadowArg;
                    return shadowArg;
                }
            }
        }
        I->getParent()->getParent()->print(errs());
        I->print(errs());errs()<<"\n";
        value->print(errs());errs()<<"\n";
        value->getType()->print(errs());errs()<<"\n";
        errs()<<value->getType()->getTypeID()<<__func__<<"Value is not a constantPointer or global\n";
        exit(-1);
    }
}

int DeIRInstructionInsert::instrumentGEP(BasicBlock::iterator &I,BlockResult &BR) {
    int skipCount=0;
    GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(&*I);
    Value* pointer = GEP->getPointerOperand();

    if(localVarPointerUseTrack.find(pointer)!=localVarPointerUseTrack.end()){
        localVarPointerUseTrack.insert(std::make_pair(GEP,pointer));
    } else{
        IRBuilder<> IRB(&*(std::next(I)));
        SmallVector<Value*, 1> Idx;
        if(isa<ShuffleVectorInst>(pointer)){
            //ShuffleVectorInst cannot be cast
            pointer->print(errs());errs()<<" instrumentGEP \n";
            I->print(errs());errs()<<"\n";
            GEP->getType()->print(errs());errs()<<"\n";
//            dereferenceAPointer(IRB,GEP,shadow_GEP,skipCount)
//            BR.outShadow[GEP]=shadow_GEP;
            return skipCount;
        }

//#if SUPPORT_BIG_OBJECT_TAINT
//        MDNode* MD = I->getMetadata(MD_STATE);
//        if(MD && !getStringFromMD(MD).compare("unsafe")){
//            dereferenceAPointer(IRB,&*I,shadowPointer,skipCount);
//            BR.outShadow[GEP] = shadowPointer;
//        }
//#else
        Value* shadowPointer = getDereferenceValueOfAPointer(I,pointer,BR,skipCount);
        for(unsigned i=1;i<GEP->getNumOperands();i++){
            Idx.push_back(GEP->getOperand(i));
        }

        Value *shadow_GEP;
        if(GEP->isInBounds()){
            shadow_GEP = IRB.CreateInBoundsGEP(shadowPointer,Idx);
        } else{
            shadow_GEP = IRB.CreateGEP(shadowPointer,Idx);
        }

        if(Instruction *i=dyn_cast<Instruction>(shadow_GEP)){
            i->setIsShadow(true);
            ++skipCount;
        }

        BR.outShadow[GEP]=shadow_GEP;
//#endif
    }
    return skipCount;
}
int DeIRInstructionInsert::instrumentSelect(BasicBlock::iterator &I, BlockResult &BR) {
    int skipCount = 0;
    SelectInst *si = dyn_cast<SelectInst>(&*I);
    if(si->getType()->isPointerTy()){
        //handle true
        Value *virtualTrueValue;
        Value *virtualFalseValue;
        Value *runtimeTrueValue;
        Value *runtimeFalseValue;

        if(localVarPointerUseTrack.find(si->getTrueValue())!=localVarPointerUseTrack.end() &&
                localVarPointerUseTrack.find(si->getFalseValue())!=localVarPointerUseTrack.end()){
            localVarPointerUseTrack.insert(std::make_pair(si,si));
            return skipCount;
        }

        if(localVarPointerUseTrack.find(si->getTrueValue())!=localVarPointerUseTrack.end()){
            runtimeTrueValue = si->getTrueValue();
            if(allocatePointers.find(si->getTrueValue())!=allocatePointers.end()){
                virtualTrueValue = allocatePointers[si->getTrueValue()];
            } else{
                Instruction *pre = dyn_cast<Instruction>(si->getTrueValue());
                assert(pre && "Select true is not a instruction");
                IRBuilder<> IRB(pre->getNextNode());
                getVirtualAddress(IRB,runtimeTrueValue,virtualTrueValue)
                allocatePointers.insert(std::make_pair(si->getTrueValue(),virtualTrueValue));
            }
        } else{
            virtualTrueValue = si->getTrueValue();
            runtimeTrueValue=getDereferenceValueOfAPointer(I,si->getTrueValue(),BR,skipCount);
        }

        if(localVarPointerUseTrack.find(si->getFalseValue())!=localVarPointerUseTrack.end()){
            runtimeFalseValue = si->getFalseValue();
            if(allocatePointers.find(si->getFalseValue())!=allocatePointers.end()){
                virtualFalseValue = allocatePointers[si->getFalseValue()];
            } else{
                Instruction *pre = dyn_cast<Instruction>(si->getFalseValue());
                assert(pre && "Select true is not a instruction");
                IRBuilder<> IRB(pre->getNextNode());
                getVirtualAddress(IRB,runtimeFalseValue,virtualFalseValue)
                allocatePointers.insert(std::make_pair(si->getFalseValue(),virtualFalseValue));
            }
        } else{
            virtualFalseValue = si->getFalseValue();
            runtimeFalseValue=getDereferenceValueOfAPointer(I,si->getFalseValue(),BR,skipCount);
        }
        si->setFalseValue(virtualFalseValue);
        si->setTrueValue(virtualTrueValue);

        IRBuilder<> IRB(&*I);
        Value *siShadowValue = IRB.CreateSelect(si->getCondition(),runtimeTrueValue,runtimeFalseValue);
        if(SelectInst *siShadowInst = dyn_cast<SelectInst>(siShadowValue)){
            siShadowInst->setIsShadow(true);
        }
        BR.outShadow[si]=siShadowValue;
    }

    return skipCount;
}
int DeIRInstructionInsert::instrumentPHI(BasicBlock::iterator &I, DataFlowResult *DFR) {
    int skipCount =0;
    PHINode *phi = dyn_cast<PHINode>(&*I);

    if(phi->getType()->isPointerTy()){
        IRBuilder<> IRB(&*(std::next(I)));
        PHINode *PHIShadow = IRB.CreatePHI(phi->getType(),phi->getNumIncomingValues());
        for(int itr=0,e=phi->getNumIncomingValues();itr!=e;++itr){
            Value* inComingValue = phi->getIncomingValue(itr);
            BasicBlock *preBB = phi->getIncomingBlock(itr);

            auto temp = DFR->result[preBB]->outShadow.find(inComingValue);
            Value * shadowPointer;
            if(temp!=DFR->result[preBB]->outShadow.end()){
                shadowPointer =temp->second;
                PHIShadow->addIncoming(shadowPointer,phi->getIncomingBlock(itr));
            } else if(localVarPointerUseTrack.find(inComingValue)!=localVarPointerUseTrack.end()){
                //there this pointer exist in stack,we first check this pointer value and then get its virtual value.
                Value * StackVirtualAddress;
                if(allocatePointers.find(inComingValue)!=allocatePointers.end()){
                    StackVirtualAddress = allocatePointers[inComingValue];
                } else{
                    Instruction * I = dyn_cast<Instruction>(inComingValue);
                    assert(I && "instrumentPHI inComingValue is not a Instruction");
                    IRBuilder<> IRBpreBB(I->getNextNode());
                    getVirtualAddress(IRBpreBB,inComingValue,StackVirtualAddress)
                    allocatePointers.insert(std::make_pair(inComingValue,StackVirtualAddress));
                }

                DFR->result[preBB]->outShadow[StackVirtualAddress]=inComingValue;
                phi->setIncomingValue(itr,StackVirtualAddress);
                PHIShadow->addIncoming(inComingValue,phi->getIncomingBlock(itr));
            } else{
                unsolvedPHIanditsValue.insert(std::pair<Value *,Value*>(inComingValue,PHIShadow));
                PHIShadow->addIncoming(inComingValue,phi->getIncomingBlock(itr));
            }
            PHIShadow->setIsShadow(true);
        }
        DFR->result[I->getParent()]->outShadow[phi]=PHIShadow;
    }
    return skipCount;
}

int DeIRInstructionInsert::instrumentCall(BasicBlock::iterator &I, BlockResult &BR) {
    int skipCount = 0;
    CallInst *CI = dyn_cast<CallInst>(&*I);
    Value *calledFunction = CI->getCalledValue();
    IRBuilder<> IRB(&*(std::next(I)));
    IRBuilder<> IRBPRE(&*I);

    if(MemIntrinsic *mi = dyn_cast<MemIntrinsic>(&*I)){
        switch (mi->getIntrinsicID()) {
            //because the uncertain of optimization, we insert logical address into reserved slots 0x20(%r15) 0x28(%r15)
            case Intrinsic::memcpy:
            case Intrinsic::memmove:
            {
                MemTransferInst *mti = dyn_cast<MemTransferInst>(&*I);
                Value * source = mti->getRawSource();
                Value * shadowSource;
                if(supportBigObject) {
                    insertValueToSlot(IRBPRE, source, inlineReserveToSlot[1])
                }
                if(localVarPointerUseTrack.find(source)!=localVarPointerUseTrack.end()){
                    shadowSource = source;
                } else{
                    if(supportBigObject){
                        shadowSource = getDereferenceValueOfAPointer_nonOptimization(I,source,BR,skipCount);
                    } else{
                        shadowSource = getDereferenceValueOfAPointer(I,source,BR,skipCount);
                    }

                }
                mti->setSource(shadowSource);


                Value * dest = mti->getRawDest();
                Value * shadowDest;
                if(supportBigObject) {
                    insertValueToSlot(IRBPRE, dest, inlineReserveToSlot[0])
                }
                if(localVarPointerUseTrack.find(dest)!=localVarPointerUseTrack.end()){
                    shadowDest = dest;
                } else{
                    if(supportBigObject){
                        shadowDest = getDereferenceValueOfAPointer_nonOptimization(I,dest,BR,skipCount);
                    } else{
                        shadowDest = getDereferenceValueOfAPointer(I,dest,BR,skipCount);
                    }
                }
                mti->setDest(shadowDest);
            }
                break;
            case Intrinsic::memset:{
                MemSetInst * memSetInst = dyn_cast<MemSetInst>(mi);
                memSetInst->setIsNoInline();
                Value * Dest = mi->getRawDest();
                Value * shadowDest;
                if(supportBigObject) {
                    insertValueToSlot(IRBPRE, Dest, inlineReserveToSlot[0])
                }
                if(localVarPointerUseTrack.find(Dest)!=localVarPointerUseTrack.end()){
                    shadowDest = Dest;
                } else{
                    if(supportBigObject){
                        shadowDest = getDereferenceValueOfAPointer_nonOptimization(I,Dest,BR,skipCount);
                    } else{
                        shadowDest = getDereferenceValueOfAPointer(I,Dest,BR,skipCount);
                    }
                }
                mi->setDest(shadowDest);
                break;
            }

            default:
                mi->print(errs());errs()<<"special function that have not handle\n";
        }
        return skipCount;
    } else if(VACopyInst *vacpy = dyn_cast<VACopyInst>(&*I)){
        Value * src = vacpy->getSrc();
        Value * dest = vacpy->getDest();
//        if(supportBigObject){
//            Value * shadowSrc = getDereferenceValueOfAPointer_nonOptimization(I,src,BR,skipCount);
//            Value * shadowDest = getDereferenceValueOfAPointer_nonOptimization(I,dest,BR,skipCount);
//            vacpy->setOperand(0,shadowDest);
//            vacpy->setOperand(1,shadowSrc);
//        } else{
            Value * shadowSrc = getDereferenceValueOfAPointer(I,src,BR,skipCount);
            Value * shadowDest = getDereferenceValueOfAPointer(I,dest,BR,skipCount);
            vacpy->setOperand(0,shadowDest);
            vacpy->setOperand(1,shadowSrc);
//        }

        return skipCount;
    }else if(VAStartInst *vaStart = dyn_cast<VAStartInst>(&*I)){
        Value * first = vaStart->getArgList();
        if(BitCastInst *bitcast = dyn_cast<BitCastInst>(first)){
            Value *src = bitcast->getOperand(0);
            Type *type = bitcast->getSrcTy()->getPointerElementType();
            {
                SmallVector<Value*, 3> Idx;
                Idx.push_back(ConstantInt::get(Int32Ty, 0));
                Idx.push_back(ConstantInt::get(Int32Ty, 0));
                Idx.push_back(ConstantInt::get(Int32Ty, 2));

                Value * overflowAddress=IRB.CreateGEP(type,src,Idx);
                cast<Instruction>(overflowAddress)->setIsShadow(true);
                Value * overflow = IRB.CreateLoad(Int8PtrTy,overflowAddress);
                cast<Instruction>(overflow)->setIsShadow(true);
                Value *overflowVirt;
                getVirtualAddress(IRB,overflow,overflowVirt)
                IRB.CreateStore(overflowVirt,overflowAddress)->setIsShadow(true);
            }

            {
                SmallVector<Value*, 3> Idx;
                Idx.push_back(ConstantInt::get(Int32Ty, 0));
                Idx.push_back(ConstantInt::get(Int32Ty, 0));
                Idx.push_back(ConstantInt::get(Int32Ty, 3));
                Value *reg_saveAddress = IRB.CreateGEP(type, src, Idx);
                cast<Instruction>(reg_saveAddress)->setIsShadow(true);
                Value *reg_save = IRB.CreateLoad(Int8PtrTy, reg_saveAddress);
                cast<Instruction>(reg_save)->setIsShadow(true);
                Value *reg_saveVirt;
                getVirtualAddress(IRB, reg_save, reg_saveVirt)
                IRB.CreateStore(reg_saveVirt, reg_saveAddress)->setIsShadow(true);
            }
        }
    }

    StringRef funcname = calledFunction->getName();
    if(calledFunction->hasName()){
        if(calledFunction->getName().startswith("llvm.")){
            // CI->print(errs());errs()<<" llvm. \n";
            return 0;
        }
        if(funcname.startswith("addressDereference")) return 0;

        if(isfuncNeedHandle(funcname)){
            //handle funcions like memcpy and etc
//Pan-pathOram: we donnot to translate the function here any more
            // Value* shadowFun=getDereferenceValueOfAPointer_controlFlow(I,calledFunction,BR,skipCount);
            // CI->setCalledFunction(shadowFun);
            int insertSlotIndext=0;
            for(unsigned i=0;i<CI->getNumArgOperands();i++){
                if(CI->getArgOperand(i)->getType()->isPointerTy()){
                    if(supportBigObject) {
                        insertValueToSlot(IRBPRE, CI->getArgOperand(i), inlineReserveToSlot[insertSlotIndext])
                    }
                    insertSlotIndext++;
                    if(supportBigObject){
                        Value * shadowVal = getDereferenceValueOfAPointer_nonOptimization(I,CI->getArgOperand(i),BR,skipCount);
                        CI->setArgOperand(i,shadowVal);
                    } else{
                        Value * shadowVal = getDereferenceValueOfAPointer(I,CI->getArgOperand(i),BR,skipCount);
                        CI->setArgOperand(i,shadowVal);
                    }

                }
            }
            // if(I->getFunction()->getName().startswith("enclave_main")){
            //     errs()<<"enclave_main printf\n";
            //     I->getFunction()->print(errs());
            // }
            return skipCount;
        }
    }

    for(unsigned i=0;i<CI->getNumArgOperands();i++){
        Value *arg = CI->getArgOperand(i);
        if(localVarPointerUseTrack.find(arg)!=localVarPointerUseTrack.end()){
            Value *stackVirtualAddr;
            if(allocatePointers.find(arg)!=allocatePointers.end()){
                stackVirtualAddr = allocatePointers[arg];
            } else{
                Instruction *instruction = dyn_cast<Instruction>(arg);
                assert(instruction &&"call arg is not a allocate Instruction");
                IRBuilder<> IRBPRE(instruction->getNextNode());
                getVirtualAddress(IRBPRE,arg,stackVirtualAddr)
                allocatePointers.insert(std::make_pair(arg,stackVirtualAddr));
            }
            CI->setArgOperand(i,stackVirtualAddr);
        }
    }
//Pan-pathOram: we donnot to translate the function here any more
//    Value* shadowFun=getDereferenceValueOfAPointer_controlFlow(I,calledFunction,BR,skipCount);
//    CI->setCalledFunction(shadowFun);

    //except some specify functions for debugging
    if(isExcludeFunction(calledFunction)){
        return  skipCount;
    }

    if( DataFlow::isRandomPoint(CI,calledFunction,noneRandomPointSet)){
        BR.outShadow.clear();
    }

    return skipCount;
}
int DeIRInstructionInsert::instrumentCmp(BasicBlock::iterator &I, BlockResult &BR) {
    int skipCount = 0;
    CmpInst *ici = dyn_cast<CmpInst>(&*I);

    Value *value;
    IRBuilder<> IRB(&*I);
    for(unsigned i=0;i<ici->getNumOperands();i++){
        value = ici->getOperand(i);
        if(value->getType()->isPointerTy()){
            if(localVarPointerUseTrack.find(value)!=localVarPointerUseTrack.end()){
                Value* virtualStackValue;
                if(allocatePointers.find(value)!=allocatePointers.end()){
                    virtualStackValue = allocatePointers[value];
                } else{
                    Instruction *instruction = dyn_cast<Instruction>(value);
                    assert(instruction && "instrumentCmp value is not instruction");
                    IRBuilder<> IRBshadow(instruction->getNextNode());
                    getVirtualAddress(IRBshadow,value,virtualStackValue);
                    allocatePointers.insert(std::make_pair(value,virtualStackValue));
                }
                skipCount+=3;
                ici->setOperand(i,virtualStackValue);
            }
        }
    }
    return skipCount;
}
int DeIRInstructionInsert::instrumentStore(BasicBlock::iterator &I, BlockResult &BR) {
    int skipCount=0;
    StoreInst *SI = dyn_cast<StoreInst>(&*I);
    Value *val = SI->getValueOperand();
    Value *addrPointer = SI->getPointerOperand();

    Value *shadowPointer;
    MDNode* MD = I->getMetadata(MD_STATE);
    if(localVarPointerUseTrack.find(addrPointer)!=localVarPointerUseTrack.end()){
        shadowPointer = addrPointer;
    }else{
#if SUPPORT_BIG_OBJECT_TAINT
       if(supportBigObject && MD && !getStringFromMD(MD).compare("unsafe")){
#else
       if(supportBigObject){
#endif
           shadowPointer= getDereferenceValueOfAPointer_nonOptimization(I,addrPointer,BR,skipCount);
       }else{
           shadowPointer= getDereferenceValueOfAPointer(I,addrPointer,BR,skipCount);
       }
        // shadowPointer= getDereferenceValueOfAPointer(I,addrPointer,BR,skipCount);
    }

    Value *stackVirtualAddress= nullptr;
    if(val->getType()->isPointerTy()){
        if(localVarPointerUseTrack.find(val)!=localVarPointerUseTrack.end()){
            if(allocatePointers.find(val)!=allocatePointers.end()){
                stackVirtualAddress = allocatePointers[val];
            } else{
                Instruction *I=dyn_cast<Instruction>(val);
                assert(I && "instrumentStore val is not a constant");
                IRBuilder<> IRB(I->getNextNode());
                getVirtualAddress(IRB,val,stackVirtualAddress)
                allocatePointers.insert(std::make_pair(val,stackVirtualAddress));
            }
        }
    }


    if(stackVirtualAddress){
        SI->setOperand(0,stackVirtualAddress);
    }
    SI->setOperand(1,shadowPointer);
    return skipCount;
}

int DeIRInstructionInsert::checkAndDerefenceInstr(BasicBlock::iterator &I,DataFlowResult *DFR) {
    int addedCount = 0;
    I->setDerefenced(true);
    BlockResult &BR = *DFR->result[I->getParent()];
    if(isa<AllocaInst>(&*I)){
        return instrumentNormalAlloc(I,BR);
    }else if(isa<CastInst>(&*I)){
        addedCount += instrumentCast(I,BR);
    }else if(isa<GetElementPtrInst>(&*I)){
        addedCount += instrumentGEP(I,BR);
    }else if(isa<LoadInst>(&*I)){
        addedCount += instrumentLoad(I,BR);
    }else if(isa<StoreInst>(&*I)){
        addedCount += instrumentStore(I,BR);
    }else if(isa<CallInst>(&*I)){
        addedCount += instrumentCall(I,BR);
    }else if(isa<PHINode>(&*I)){
        addedCount += instrumentPHI(I,DFR);
    } else if(isa<SelectInst>(&*I)){
        addedCount += instrumentSelect(I,BR);
    }else if(isa<CmpInst>(&*I)){
        addedCount += instrumentCmp(I,BR);
    } else if(isa<VAArgInst>(&*I)){
    } else if(I->getType()->isPointerTy()){
        //call
        errs()<<"\n----------\n";
        I->print(errs());
        errs()<<__func__<<" find pointers that we have not handled\n";
        exit(-1);
    }
    return addedCount;
}

bool DeIRInstructionInsert::constructBBDereferenceSet(DataFlowResult *DFR, BasicBlock *BB,
                                                      SmallVector<BasicBlock *,4> preBBSet) {

    bool isChanged = false;
    //we start from the values needed by this block.
    for(auto itr:DFR->result[BB]->needObjs){
        if(!itr.second) continue;
        if(localVarPointerUseTrack.find(itr.first)!=localVarPointerUseTrack.end()) continue;
        if(isa<AllocaInst>(itr.first)) continue;
        Value * inValue = itr.first;
        if(inValue->getType()->isIntegerTy()){
            inValue->print(errs()); errs()<<"we find a IntegerTy\n";
            continue;
        }
        std::map<Value*,SmallVector<BasicBlock*,4>> shadowValueSet;

        //search the derefereced value from the preBB
        for(auto preBB:preBBSet){
            auto shadowValue = DFR->result[preBB]->outShadow.find(inValue);
            if(shadowValue!=DFR->result[preBB]->outShadow.end())
                shadowValueSet[shadowValue->second].push_back(preBB);
        }

        auto tempPHIShadowItr = DFR->result[BB]->phiForShadowValue.find(inValue);
        //for every needed value, we use a PHI to hold all the shadow values that come from all pre blocks.
        PHINode *phiShadowValue;
        if(tempPHIShadowItr==DFR->result[BB]->phiForShadowValue.end()){
            IRBuilder<> IRB(BB,BB->begin());
            phiShadowValue=IRB.CreatePHI(inValue->getType(),preBBSet.size());
            phiShadowValue->setIsShadow(true);
            for(auto shadowItr:shadowValueSet){
                for(auto bb:shadowItr.second)
                    phiShadowValue->addIncoming(shadowItr.first,bb);
            }
            //add phi into outshadow
            DFR->result[BB]->outShadow[inValue]= phiShadowValue;
            DFR->result[BB]->phiForShadowValue[inValue] = phiShadowValue;
            isChanged = true;
        } else{
            phiShadowValue = tempPHIShadowItr->second;
            //itr bb to find the bb that the phi incoming bb set does not contain.
            for(auto shadowItr:shadowValueSet){
                for(auto bb:shadowItr.second){
                    if(phiShadowValue->getBasicBlockIndex(bb)==-1){
                        phiShadowValue->addIncoming(shadowItr.first,bb);
                    }
                }
            }
        }

    }

    //dereference each Instruction in this basicBlock
    for(BasicBlock::iterator BBI=BB->begin(),BBE=BB->end();BBI!=BBE;BBI++){
        if(BBI->isShadow() || BBI->isDereferenced()) continue;
        isChanged |= checkAndDerefenceInstr(BBI,DFR);
    }

    //generate derefernce value for subneed
    for(auto valueItr:DFR->result[BB]->subBBneedObjs){
        if(!valueItr.second) continue;
        //check whether we have generated the dereference value of these pointer
        auto temp = DFR->result[BB]->outShadow.find(valueItr.first);
        if(temp!=DFR->result[BB]->outShadow.end()) {
            if(temp->second)
                continue;
        }
        //if the preBlock's outShadow contains the subneed
//        if(preBBSet.size()==1){
//            errs()<<"   generating11\n";
//            BasicBlock *preBB = *preBBSet.begin();
//            auto temp = DFR->result[preBB]->outShadow.find(valueItr.first);
//            if(temp!=DFR->result[preBB]->outShadow.end()){
//                Value *shadowValue = temp->second;
//                if(shadowValue){
//                   DFR->result[BB]->outShadow[valueItr.first]=shadowValue;
//                    continue;
//                }
//            }
//        }

        //if it's an allocate instruction
        if(isa<AllocaInst>(valueItr.first)) continue;

        if(localVarPointerUseTrack.find(valueItr.first)!=localVarPointerUseTrack.end()){
            continue;
        }
        //generate dereference Value before terminate instruction
        if(isa<ConstantPointerNull>(valueItr.first)){
            DFR->result[BB]->outShadow[valueItr.first]=valueItr.first;
            continue;
        }
        if(isa<UndefValue>(valueItr.first)){
            errs()<<"find undef<<<\n";
            DFR->result[BB]->outShadow[valueItr.first]=valueItr.first;
            continue;
        }
        IRBuilder<> IRB(BB->getTerminator());
        _dereferenceAPointer(IRB,valueItr.first,shadowPointer);
        DFR->result[BB]->outShadow[valueItr.first]=shadowPointer;
        isChanged = true;
    }
    return isChanged;
}

BasicBlock* DeIRInstructionInsert::itrSplitBBIntoSmallOnes(BasicBlock *BB, DominatorTree *DT,
                                                           LoopInfo *LI) {
    if(BB->size()>400){
        unsigned count=0;
        BasicBlock::iterator itr= BB->begin();
        for(; count<(BB->size()/2) && itr!=BB->end();count++,itr++ ){}
        BasicBlock *secondBB= SplitBlock(BB,&*itr,DT,LI);
        itrSplitBBIntoSmallOnes(BB,DT,LI);
        itrSplitBBIntoSmallOnes(secondBB,DT,LI);
    }

    return nullptr;
}
bool DeIRInstructionInsert::runAnalysisPass(IterativeModulePass *Pass,Module &M) {
    bool changed = false;
    changed |=Pass->doModuleInitialization(&M);
    for(Function &F:M){
       changed |= Pass->runOnFunction(&F);
    }
    changed |=Pass->doModuleFinalization(&M);

    return changed;
}

bool DeIRInstructionInsert::runOnModule(Module &M) {
    bool isChanged= false;
    GlobalContext GlobalCtx;

    // whether we should support the data objects that are larger than a block size.
    if(supportBigObject){
        //do taint analysis on the Module
        bool globalTagged = false;
        unSafeOBjects.initGM(&M,&GlobalCtx);

        //find all unsafe sources in a module.
        for(Function &F:M){
            if(!shouldInstrument(&F))
                continue;
            unSafeOBjects.DT = &getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
            unSafeOBjects.LI = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
            unSafeOBjects.SE = &getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
            unSafeOBjects.trickyOne = unSafeOBjects.SE->getConstant(Type::getInt64Ty(M.getContext()),1);

            //setup the global and boundary
            if(!globalTagged){
                unSafeOBjects.findUnSafeGlobals(M);
                globalTagged = true;
            }

            unSafeOBjects.findUnSafeAllocation(F);
        }

        for(auto &itrF:unSafeOBjects.UnSafeMallocInst){
            errs()<<itrF.first->getName()<<" function name\n";
            for(auto &itr: itrF.second){
                itr.first->print(errs());errs()<<"\n";
                errs()<<itr.second<<"\n";
            }
        }

        //propagate unSafes in a module.
        unSafeOBjects.runOnModule(M);
    }
//    if(1){
//        for(Function &F:M){
//            errs()<<F.getName()<<"\n";
//            if(F.getName().equals("enclave_main")){
//                F.print(errs());errs()<<"\n";
//                for(inst_iterator i=inst_begin(F),e=inst_end(F);i!=e;++i){
//                    Instruction *I = &*i;
//                    I->print(outs());
////                    ScalarEvolution *SCE = &getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
//                    std::string tempStr= getAnnotation(I,&M);
//                    if(!tempStr.empty()){
//                        outs()<<"\t\t\t\t getAnnotation "<<getAnnotation(I,&M)<<"\n";
//                    } else{
//                        outs()<<"\n";
//                    }
//                }
//            }
//        }
//    }

    //start to insert dereference instruction to the program

    for(Function &F:M){
        if(!shouldInstrument(&F)){
            continue;
        }

        if(runFunction(F)){
            isChanged = true;
        }
    }
    return isChanged;
}

bool DeIRInstructionInsert::runFunction(Function &F) {
    if(F.getName() == "Redereference64")
        return false;
    if(F.getName() == "addressDereference64")
        return false;
    if(F.getName() == "fillPagetable")
        return false;

    if(F.getName() == "reserveTo0Slot")
        return false;
    if(F.getName() == "reserveTo1Slot")
        return false;

    currentFunction = &F;

    bool changed = false;
    LoopInfo *LI_1 = &getAnalysis<LoopInfoWrapperPass>(F).getLoopInfo();
    DominatorTree *DT = &getAnalysis<DominatorTreeWrapperPass>(F).getDomTree();
    ScalarEvolution *SE = &getAnalysis<ScalarEvolutionWrapperPass>(F).getSE();
    AssumptionCache *AC =
            &getAnalysis<AssumptionCacheTracker>().getAssumptionCache(F);
    bool PreserveLCSSA = mustPreserveAnalysisID(LCSSAID);
    for (LoopInfo::iterator I = LI_1->begin(), E = LI_1->end(); I != E; ++I)
        changed |= simplifyLoop(*I, DT, LI_1, SE, AC, PreserveLCSSA);

    for(auto &BB:F){
        itrSplitBBIntoSmallOnes(&BB,DT,LI_1);
    }

    //(liveness analysis) pre-calculate a function's body to find out each block:
    // 1. the shadow values that it can get from pre-blocks
    // 2. the shadow value that it can pass to its post-blocks
    DataFlow* dataFlow =new DataFlow();
    DataFlowResult* dataFlowResult=dataFlow->init(F,*LI_1,DT,noneRandomPointSet);

    SmallVector<BasicBlock*,16> basicBlockSet;//basicBlocks that need to be dereferenced;
    SmallVector<BasicBlock*,16> handledBlockSet;
    BasicBlock &entry = F.getEntryBlock();

    //then insert shadow values with the pre-calculated liveness analysis
    basicBlockSet.push_back(&entry);
    while(basicBlockSet.size()){
        BasicBlock *basicBlock = basicBlockSet.pop_back_val();
        if(std::find(handledBlockSet.begin(),handledBlockSet.end(),basicBlock)==handledBlockSet.end()){
            handledBlockSet.push_back(basicBlock);
        }

        SmallVector<BasicBlock *,4> preBBset;
        for(pred_iterator PI = pred_begin(basicBlock), PE = pred_end(basicBlock);PI!=PE;PI++){
            preBBset.push_back(*PI);
        }
        bool isUpdated = constructBBDereferenceSet(dataFlowResult,basicBlock,preBBset);

        const TerminatorInst *TInst = basicBlock->getTerminator();
        for (unsigned I = 0, NSucc = TInst->getNumSuccessors(); I < NSucc; ++I) {
            BasicBlock *Succ = TInst->getSuccessor(I);
            bool ishandled = true;
            if(std::find(handledBlockSet.begin(),handledBlockSet.end(),Succ)==handledBlockSet.end()){
                ishandled = false;
            }

            if(isUpdated || !ishandled)
                basicBlockSet.push_back(Succ);
        }

    }
    Value *inComingValueShadow;
    SmallVector<Value *,4> solvedPHIValue;
    //handle those unsolved values in PHI
    for(auto itr:unsolvedPHIanditsValue){
        PHINode *phi = dyn_cast<PHINode>(itr.second);
        Value *unDereferencedInComingValue = itr.first;

        BasicBlock *preBB;
        //find unsolved operand index
        int index=0;
        for(unsigned i=0;i<phi->getNumIncomingValues();i++){
            if(unDereferencedInComingValue==phi->getIncomingValue(i)){
                preBB = phi->getIncomingBlock(i);
                index = i;
            }
        }

        if(isa<ConstantPointerNull>(unDereferencedInComingValue)){
            //we do not need to Derefence a null
            inComingValueShadow= unDereferencedInComingValue;
        } else{
            //look for the dereferenced value of the unsolved one.
            auto temp = dataFlowResult->result[preBB]->outShadow.find(unDereferencedInComingValue);
            if(temp != dataFlowResult->result[preBB]->outShadow.end()){
                inComingValueShadow = temp->second;
            } else{
                inComingValueShadow = nullptr;
            }
        }

        //if we have not found the dereferenced value and its a value stored in stack
        if(!inComingValueShadow && localVarPointerUseTrack.find(unDereferencedInComingValue)!=localVarPointerUseTrack.end()){
            //its a local stack value, we need to modify the nonshadow phi.
            PHINode *prePhi = dyn_cast<PHINode>(phi->getPrevNode());
            assert(prePhi && "none phi infront of shadowphi");
            unsigned index=0;
            for(;index < prePhi->getNumIncomingValues();index++){
                if(prePhi->getIncomingValue(index)==unDereferencedInComingValue){
                    break;
                }
            }
            assert(prePhi->getIncomingValue(index)==unDereferencedInComingValue && "do not find incomingValue in this phi");
            if(allocatePointers.find(unDereferencedInComingValue)!=allocatePointers.end()){
                prePhi->setIncomingValue(index,allocatePointers[unDereferencedInComingValue]);
            } else{
                Instruction *instruction = dyn_cast<Instruction>(unDereferencedInComingValue);
                IRBuilder<> IRB(instruction->getNextNode());
                Value *inComingValueVirtualAddress;
                getVirtualAddress(IRB,unDereferencedInComingValue,inComingValueVirtualAddress)
                allocatePointers.insert(std::make_pair(unDereferencedInComingValue,inComingValueVirtualAddress));
                prePhi->setIncomingValue(index,inComingValueVirtualAddress);
            }
            continue;
        }

        //dereference the value
        if(!inComingValueShadow){
            //it may exist in a critical exitBlock
            if(phi->getParent()->getSinglePredecessor()){
                IRBuilder<> IRBNEXT(phi->getNextNode());
                _dereferenceAPointer(IRBNEXT,unDereferencedInComingValue,shadowinComingValue)
                phi->replaceAllUsesWith(shadowinComingValue);
                solvedPHIValue.push_back(phi);
                dataFlowResult->result[phi->getParent()]->outShadow[phi->getPrevNode()]=shadowinComingValue;
                continue;
            }

            phi->getParent()->getParent()->print(errs());
            if(localVarPointerUseTrack.find(unDereferencedInComingValue)!=localVarPointerUseTrack.end()){
                errs()<<"find allocate value here\n";
            }
            dataFlow->printResults(dataFlowResult,preBB);
            dataFlow->printResults(dataFlowResult,phi->getParent());
            unDereferencedInComingValue->print(errs());errs()<<"here12\n";
            phi->print(errs());
            exit(-1);
        }
        //replace the value with the dereferenced value.
        phi->setIncomingValue(index,inComingValueShadow);
    }

    //elimit PHIs that has none or only one same values in each block
    for(Function::iterator BBI=F.begin(),BBE=F.end();BBI!=BBE;BBI++){
        auto blockResult= dataFlowResult->result.find(&*BBI);
        if(blockResult==dataFlowResult->result.end()) continue;

        for(auto itr:blockResult->second->phiForShadowValue){
            Value *srcValue = itr.first;
            PHINode *phiNode = itr.second;
            std::map<Value *,SmallVector<BasicBlock *,4>> valueMap;
            for(int i=0,e=phiNode->getNumIncomingValues();i!=e;i++){
                Value *incomingValue = phiNode->getIncomingValue(i);

                valueMap[incomingValue].push_back(phiNode->getIncomingBlock(i));
            }

            //check the number of Incomingvalue and pre block
            if(int num=phiNode->getNumIncomingValues()){
                SmallVector<BasicBlock*, 8> Preds(pred_begin(&*BBI), pred_end(&*BBI));
                int succ = Preds.size();
                if(succ!=num){
                    std::map<BasicBlock *,int> blockMap;
                    //then the phi incoming num does not equal to the succ
                    //1. check whether there are missing incomming blocks
                    // and record the number of each block in pred_blocks
                    for(pred_iterator PI = pred_begin(&*BBI), PE = pred_end(&*BBI);PI!=PE;PI++){
                        assert(phiNode->getBasicBlockIndex(*PI)>=0 && "missing income block");
                        assert(phiNode->getIncomingValueForBlock(*PI) && "income value invalid");
                        if(blockMap.find(*PI)==blockMap.end()){
                            blockMap.insert(std::make_pair(*PI,1));
                        } else{
                            blockMap[*PI]+=1;
                        }
                    }
                    //2. they pass the check, so that must be same incoming value inside, we random chose one to insert.
                    for(auto itr:blockMap){
                        int num = itr.second;
                        while(num>1){
                            Value *insertValue = phiNode->getIncomingValueForBlock(itr.first);
                            phiNode->addIncoming(insertValue,itr.first);
                            num--;

                        }
                    }
                }
            }
            //if the node has no or only one incoming block, they would be replaced.
            if(valueMap.size()==0){
                IRBuilder<> IRB(BBI->getFirstNonPHI());
                _dereferenceAPointer(IRB,srcValue,shadowPointer)
                phiNode->replaceAllUsesWith(shadowPointer);
                phiNode->eraseFromParent();
            } else if(valueMap.size()==1){
                Value* shadowPointer = valueMap.begin()->first;
                phiNode->replaceAllUsesWith(shadowPointer);
                phiNode->eraseFromParent();
            }
        }

        }

    delete dataFlow;
    reset();
    return changed;
}

ModulePass *llvm::createDeIRInstructionInsertFunctionPass(bool CompileKernel, bool Recover, bool UseAfterScope) {
    return new DeIRInstructionInsert();
}
StringRef DeIRInstructionInsert::getPassName() const {
    return "DeIRInstrInsert";
}

void DeIRInstructionInsert::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addPreserved<LoopInfoWrapperPass>();

    AU.addRequired<AssumptionCacheTracker>();

    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addPreserved<DominatorTreeWrapperPass>();

    AU.addRequiredID(LoopSimplifyID);
    AU.addRequired<ScalarEvolutionWrapperPass>();
    AU.addPreserved<ScalarEvolutionWrapperPass>();

    AU.addPreserved<BasicAAWrapperPass>();
    AU.addPreserved<AAResultsWrapperPass>();
    AU.addPreserved<GlobalsAAWrapperPass>();
    AU.addPreserved<SCEVAAWrapperPass>();
    AU.addPreservedID(LCSSAID);
    AU.addPreserved<DependenceAnalysisWrapperPass>();
    AU.addPreservedID(BreakCriticalEdgesID);  // No critical edges added.
}
