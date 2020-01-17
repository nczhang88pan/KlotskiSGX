//
// Created by alax on 6/6/18.
//

#include "unSafeObject.h"
#include "Allocation.h"
#include "Annotation.h"
#include "Global.h"
#include "CallGraph.h"
#include "unordered_set"

using namespace llvm;

static unsigned VerboseLevel=0;

static std::map<std::string, int> SpecialFunctionArgTaintSet = {
        { "mspace_malloc", 1 },
};

static bool isSpecialFunctionToTaint(Function *F, unsigned &argTaintedState){
    bool findInSet = false;
    auto itr = SpecialFunctionArgTaintSet.find(F->getName().str());
    if(itr==SpecialFunctionArgTaintSet.end())
        return false;
    argTaintedState |= itr->second;
    return true;
}

static inline bool setTag(SimpleTaintMap &map, std::string &Id, int tag) {
    auto itr = map.find(Id);
    if (itr == map.end() || itr->second < tag) {
        map[Id] = tag;
        return true;
    }
    return false;
}
void UnSafeOBjects::reset(Function *F) {
//    CurrentLContext.clear();
//    CurrentGContext.clear();
//    CurrentTraceContext.clear();
    CurrentCallStack.clear();
    CurrentCallStack.insert(std::make_pair(F,0));
}
bool UnSafeOBjects::initGM(Module *M,GlobalContext *ctx) {
    Ctx = ctx;
    CurrentModule = M;
    DL = &(M->getDataLayout());
    unSafeAllocations.clear();
    unSafePropagation.clear();
    unSafeArgment.clear();
    functionNeedUpdate.clear();
    TracingFunctionWorkSet.clear();

    //init CallGraph
    bool changed = false;
    CallGraphPass CGPass(ctx);
    changed |=CGPass.doModuleInitialization(M);
    for(Function &F:*M){
        changed |= CGPass.runOnFunction(&F);
    }
    changed |=CGPass.doModuleFinalization(M);
//    CGPass.dumpFuncPtrs();
//    CGPass.dumpCallees();
//    CGPass.dumpCallers();

    return changed;
}

int UnSafeOBjects::setTaint(Value *value, struct TracedFunction * currentTF) {
    bool isUpdated =false;

    if(Instruction *I = dyn_cast<Instruction>(value)){
        InstTaintedStateSet &currentITS = currentTF->instTaintedStateSet;


        auto itr = currentITS.find(I);
        if(itr == currentITS.end()){
            currentITS.insert(I);
            isUpdated = true;
        }

        MDNode* MD = I->getMetadata(MD_Taint);
        std::string stag = "unsafe";
        if(MD!= nullptr && getStringFromMD(MD).compare(stag)){
            return isUpdated;
        }
        STA_DEBUG("set value= "<<*value<<" as "<<stag);

        LLVMContext &VMCtx = I->getContext();
        MD = MDNode::get(VMCtx,MDString::get(VMCtx,stag));
        I->setMetadata(MD_Taint,MD);

        if(!isa<CallInst>(I))
            return isUpdated;
    }


    std::string Id = getAnnotation(value,CurrentModule,&UnSafeMallocInst, currentTF);
    if(!Id.empty()){

        if(isa<Argument>(value)){
            if(currentTF->argTaintStateAnnotationSet.insert(Id).second){
                isUpdated = true;
            }
            return isUpdated;
        }

        if(setTag(CurrentGContext,Id,UNSAFE_TAG)){
            STA_DEBUG("setTaint CurrentGContext ID = "<< Id << "; value = "<<*value);
            isUpdated = true;
        }
    }

    return isUpdated;
}

int UnSafeOBjects::getTaint(Value *value,struct TracedFunction * currentTF) {
    if(Instruction *I = dyn_cast<Instruction>(value)){
        InstTaintedStateSet &currentITS = currentTF->instTaintedStateSet;

        if(currentITS.count(I)){
            return UNSAFE_TAG;
        }

        if(!isa<CallInst>(I))
            return CLEAN_TAG;
    }

    std::string Id = getAnnotation(value,CurrentModule,&UnSafeMallocInst,currentTF);

    if(!Id.empty()){
        //if it is an arg;
        if(currentTF->argTaintStateAnnotationSet.count(Id)){
            return UNSAFE_TAG;
        }

        auto itr = CurrentGContext.find(Id);
        if(itr != CurrentGContext.end()){
            return itr->second;
        }
    }
    return CLEAN_TAG;
}

bool UnSafeOBjects::instrumentCall(Function *func, Instruction *instruction, Value *ptr) {

    bool isNewArgTag=false;
    CallInst *CI = dyn_cast<CallInst>(instruction);
    Function *calledFunction = CI->getCalledFunction();
    //if we do not know the function
    if(!calledFunction){
        return false;
    }

    if(calledFunction->isVarArg()){
        return false;
    }

    if(functionShouldBeIgnored(calledFunction)){
        return false;
    }

    //get the xth of the ptr
    int pos=-1;
    for(unsigned i=0;i<CI->getNumArgOperands();i++){
        if(ptr == CI->getArgOperand(i)){
            pos = i;
            break;
        }
    }

    assert(pos!=-1 && "cannot find ptr in this call instrucion");
    auto item = unSafeArgment.find(calledFunction);
    if(item==unSafeArgment.end()){
        DenseSet<int> *tempSet = new DenseSet<int>();
        tempSet->insert(pos);
        unSafeArgment.insert(std::make_pair(calledFunction,tempSet));
        //thus, the argument changed
        functionNeedUpdate.insert(calledFunction);
        isNewArgTag=true;

    }else{
        if(!item->second->count(pos)){
            item->second->insert(pos);
            functionNeedUpdate.insert(calledFunction);
            isNewArgTag=true;
        }
    }

    return isNewArgTag;
}

static std::set<std::string> IgnoredGlobals = {
        "_virtual_stack_r13",
        "_virtual_stack_save",
        "_loader_stack_save",
        "rax_backup",
        "_ms",
        "_ms_8k",
        "_ms_large",
        "free.ms",
        "malloc.ms"
};

bool UnSafeOBjects::isIgnoredGlobal(Value *value) {
    return IgnoredGlobals.find(value->getName())!=IgnoredGlobals.end();
}

void UnSafeOBjects::insertToSet(DenseSet<Value *> &set, Value *frunction) {
    //we should first check

}

bool UnSafeOBjects::checkGlobalPointerStore(Function &function1, Instruction *store) {
    //check whether this store is tainted
    bool isFind=false;
    DenseSet<Instruction*> *denseSet;
    for(auto itr:unKnownGlobalPointerUserMap){
        denseSet=itr.second;
        auto targetItr=denseSet->find(store);
        if(targetItr!=denseSet->end()){
            //so we find this Set should be tagged
            isFind=true;
            break;
        }
    }

    if(isFind){
        //then we should add those pointers into unSafeAllocations
        while (!denseSet->empty()){
            Instruction * itr = *denseSet->begin();
            denseSet->erase(denseSet->begin());
            if(itr->getOpcode()==Instruction::Load){
                Function* parentFunc = itr->getFunction();
                setUnsafe(parentFunc,itr);
                functionNeedUpdate.insert(parentFunc);
            }
        }
    }

    return false;
}

bool UnSafeOBjects::instrumentRet(Function *func, Instruction *instruction) {
//    instruction->print(errs());errs()<<"\n";
//    assert((instruction->getNumOperands()!=0 && instruction->getOperand(0)->getType()->isPointerTy()) && "none ret pointer");
    for(auto itr:func->users()){
        if(Instruction* inst = dyn_cast<Instruction>(itr)){
            Function *parentFunc = inst->getFunction();
            auto pair = unSafeAllocations.find(parentFunc);
            DenseSet<Value*> * denseSet;
            if(pair==unSafeAllocations.end()){
                denseSet = new DenseSet<Value*>();
                unSafeAllocations.insert(std::make_pair(parentFunc,denseSet));
            } else{
                denseSet=pair->second;
            }
            if(!denseSet->count(inst)){
                denseSet->insert(inst);
                functionNeedUpdate.insert(parentFunc);
            }
        }
    }

    return false;
}
bool UnSafeOBjects::isIgnoredFunction(Function *func) {
    bool isIgnoredFunc = false;
    if(isAllocationFunc(func)){
        isIgnoredFunc = true;
    }
    StringRef name = func->getName();
    if(!name.compare("memcmp") ||
        !name.compare("strcmp") ||
        !name.compare("strncmp")){
        isIgnoredFunc = true;
    }
    return isIgnoredFunc;
}

bool UnSafeOBjects::handleSpecifyCallInst(CallInst *instruction, int &taint,struct TracedFunction * currentTF) {
    bool ret = false;
    Function * calledFun = currentTF->func;
    if(calledFun && isAllocationFunc(calledFun)){
        ret = true;
        if(UnSafeMallocInst.count(calledFun)){
            if(UnSafeMallocInst[calledFun].count(instruction)){
                currentTF->instTaintedStateSet.insert(instruction);
                return ret;
            }
        }
        taint = false;
    }

    return ret;
}
bool UnSafeOBjects::handleAsm(CallInst *CI,struct TracedFunction * currentTF) {
    bool taint = false;
    InlineAsm *ASM = dyn_cast<InlineAsm>(CI->getCalledValue());
    assert(ASM);

    for (unsigned no = 0, ne = CI->getNumArgOperands(); no != ne; ++no) {
        Value *Arg = CI->getOperand(no);
        //STA_DEBUG("Handle asm arg " << *Arg << "\n");
        if (Arg->getType()->isPointerTy())
            taint |= getTaint(Arg,currentTF);
    }

    if (taint) {
        std::string as = ASM->getAsmString();
        // handle load
        if (as.find("ldr") != std::string::npos) {
            STA_DEBUG("INLINE ASM LOAD");
            return taint;
        } else {
            // FIXME handle other cases
            WARNING("Unhandled asm " << as << "\n");
            taint = false;
        }
    }

    return taint;
}

struct TracedFunction* UnSafeOBjects::getTFResult(Function *calledF, unsigned argTaintState) {
    if(CurrentTContext.count(calledF)){
        for(auto itr:CurrentTContext[calledF]){
            if(itr->argTaintedState == argTaintState){
                return itr;
            }
        }
    } else{
        SmallVector<struct TracedFunction *,4> vector;
        CurrentTContext.insert(std::make_pair(calledF,vector));
    }
    return nullptr;
}

// getElementInst is the most important.
bool UnSafeOBjects::forwardTaint(Function &F,struct TracedFunction * currentTF) {
    Value *SV;
    FuncSet *FS;
    int taint;
    std::string Id;
    bool changed = false;
    CallInst *CI = nullptr;
    struct TracedFunction * calledTF = nullptr;
    InstTaintedStateSet & currentITS = currentTF->instTaintedStateSet;
//    for (inst_iterator i = inst_begin(F), e = inst_end(F); i != e; ++i) {
//        Instruction *I = &*i;
//        I->print(errs());errs()<<"\n";
//    }

    for (inst_iterator i = inst_begin(F), e = inst_end(F); i != e; ++i) {
        Instruction *I = &*i;
        //check whether this instruction is tainted
        bool MD = (currentITS.count(I) !=0);

        // if an instruction is already tainted, ignore unless is a call
        if(MD && !isa<CallInst>(I))
            continue;

        taint=0;
        switch (I->getOpcode()){
            case Instruction::Store:{
                //if value is tained, thus the pointer's ID should be marked as tainted,
                //any loader from the ID should be also tainted.
                SV = I->getOperand(0);
                taint = getTaint(SV,currentTF);
                //if the value is tainted
                if(taint==UNSAFE_TAG){
                    Id = getStoreId(cast<StoreInst>(I),&UnSafeMallocInst); //get pointer's Id,
                    if(Id.empty()){
                        WARNING("Empty ID for store " << *I << "\n");
                        break;
                    }
                    STA_DEBUG(" store insert Special Id into " << *I << Id);
                    setTag(SpecialAddressId, Id, UNSAFE_TAG);

                    StringRef ID(Id);
                    if(ID.startswith("arg.")){
//                        STA_DEBUG(" we find special arg " << *I << Id);
                        currentTF->argTaintStateAnnotationSet.insert(Id);
                    }
                }
                //for instrumentation, we care more about the pointer.
                SV = I->getOperand(1);
                taint = getTaint(SV,currentTF);
                if(taint==UNSAFE_TAG){
                    //thus this store is unsafe, we should mark it
                    LLVMContext &VMCtx = I->getContext();
                    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                    I->setMetadata(MD_STATE,MD);
                }
                break;
            }
            case Instruction::Load:{

                //check whether it loads from an unsafe place.
                SV = cast<LoadInst>(I)->getPointerOperand();
                taint = getTaint(SV,currentTF);
                if(taint==UNSAFE_TAG){
                    LLVMContext &VMCtx = I->getContext();
                    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                    I->setMetadata(MD_STATE,MD);
                }

                //get the target pointer's Id, to find whether it is a sensitive pointer.
                Id = getLoadId(cast<LoadInst>(I),&UnSafeMallocInst);
                if(Id.empty()){
                    WARNING("Empty ID for load" << *I<<"\n");
                    break;
                }

                //if we find this value in SpecialAddressId. the loader should be propogated.
                if(SpecialAddressId.count(Id)){
                    taint = SpecialAddressId[Id];
                    if(!MD) STA_DEBUG("taint load, id= "<< Id );
                    break;
                }

//                //check
//
//                //lookup taint source
//                if(isUnSafeSource(&F,cast<LoadInst>(I)->getPointerOperand())){
//                    taint = UNSAFE_TAG;
//                    CurrentGContext[Id] = taint;
//                }
            }
                break;
            case Instruction::Call:{
                CI = cast<CallInst>(I);

                if(CI->isInlineAsm()){
                    handleAsm(CI,currentTF);
                    break;
                }

                if(handleSpecifyCallInst(CI,taint,currentTF)){
                    break;
                }

                //possible Callees here
                FS = &Ctx->Callees[CI];
                //if the FS is empty
                if(FS->empty()){
                    Function *calledFunction = CI->getCalledFunction();
                    if(calledFunction){
                        assert(calledFunction->getName().startswith("llvm."));
                        //TODO:klotski we may have to taint the llvm.va
                    } else{
                        //then we should taint this unkonwn one
                        for(unsigned no = 0, ne = CI->getNumArgOperands();no!=ne;++no){
                            Value *Arg = CI->getArgOperand(no);
                            // propagate all pointer args
                            if(Arg->getType()->isPointerTy()){
                                changed |= setTaint(Arg,currentTF);
                                if(changed)
                                    STA_DEBUG("taint actual, id = " << Id << ", V = " << *Arg );
                            }
                        }

                        //propagate from ret
                        taint = UNSAFE_TAG;
                    }

                    break;
                }
                //otherwise, we iter the callees
                for(Function *CF : *FS){
                    //ignore some function that we do not need to handle
                    if(isIgnoredFunction(CF))
                        continue;

                    StringRef name = CF->getName();
                    // handle special function
                    if (!name.compare("memcpy") ||
                        name.startswith("llvm.memcpy") ||
                        name.find("strlcpy") != StringRef::npos ||
                        name.find("strcpy") != StringRef::npos) {
                        Value *Arg0 = CI->getArgOperand(0);
                        Value *Arg1 = CI->getArgOperand(1);
                        if ((taint = getTaint(Arg1,currentTF)))
                            changed |= setTaint(Arg0, currentTF);

                        continue;
                    }

                    //get args' taint state and find out suitable tf
                    unsigned argTaintState=0;
                    bool propagated = false;
                    for(unsigned no=0, ne = CI->getNumArgOperands(); no!= ne; ++no){
                        Value *Arg = CI->getArgOperand(no);
                        taint = getTaint(Arg,currentTF);
                        if(taint == UNSAFE_TAG){
                            argTaintState += (1<<no);
                        }
                    }

                    //if the args' taint states of the called function are not included, propagate this function.
                    calledTF =getTFResult(CF,argTaintState);
                    if(!calledTF){
                        calledTF = new struct TracedFunction();
                        calledTF->func = CF;
                        calledTF->argTaintedState = argTaintState;
                        calledTF->propagateOut = 0;
                        calledTF->retTainted = false;
                        CurrentTContext[CF].push_back(calledTF);

                        propagated = true;
                    }

                    if(propagated){
                        //thus the workSet changed, we should re-propagated this functhion
                        STA_DEBUG("Check callee " << CF->getName() << " of " << F.getName() );
                        runOnFunction(*CF,calledTF);
                    }

                    //propagate from arg
                    for(unsigned no = 0, ne = CI->getNumArgOperands();no!=ne;++no){
                        Value *Arg = CI->getArgOperand(no);
                        // propagate back to arg
                        Id = getArgId(CF,no);
                        if(Arg->getType()->isPointerTy() && (calledTF->argTaintStateAnnotationSet.count(Id))){
                            changed |= setTaint(Arg,currentTF);
                            if(changed)
                                STA_DEBUG("taint actual, id = " << Id << ", V = " << *Arg );
                        }
                    }

                    //propagate from ret
                    taint = calledTF->retTainted;
                }
            }
                break;
            case Instruction::Ret:
                if(I->getNumOperands()!=0){
                    taint = getTaint(I->getOperand(0),currentTF);
                    if(taint){
                        STA_DEBUG("taint ret, F = " << F.getName() );
                        Id = getRetId(&F);
                        setTag(CurrentGContext,Id,taint);
                        currentTF->retTainted = true;
                    }
                }
                break;
            case Instruction::Select:
                taint = getTaint(I->getOperand(1),currentTF) > taint ? getTaint(I->getOperand(1),currentTF) : taint;
                taint = getTaint(I->getOperand(2),currentTF) > taint ? getTaint(I->getOperand(2),currentTF) : taint;
                break;
            case Instruction::GetElementPtr:
                //currently in order to support all objects, we taint all except
                
                //we first check the state of the pointer
                taint = getTaint(I->getOperand(0),currentTF);
                if(taint == UNSAFE_TAG){
                    LLVMContext &VMCtx = I->getContext();
                    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                    I->setMetadata(MD_STATE,MD);
                    break;
                }
                Id = getAnnotation(I, CurrentModule,&UnSafeMallocInst);
                if (Id.empty()) {
                    WARNING("Empty ID for GEP " << *I << "\n");
                    taint = getTaint(I->getOperand(0),currentTF);
                    if(taint==UNSAFE_TAG){
                        LLVMContext &VMCtx = I->getContext();
                        MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                        I->setMetadata(MD_STATE,MD);
                    }
                    break;
                }
                if (CurrentGContext.count(Id)) {
                    taint = CurrentGContext[Id];
                    LLVMContext &VMCtx = I->getContext();
                    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                    I->setMetadata(MD_STATE,MD);
                    break;
                }

                //check from the source
                if(isUnSafeSource(&F,dyn_cast<GetElementPtrInst>(I)->getPointerOperand()) || MD){
                    STA_DEBUG("taint sensitive GEP " << *I << ", Id = " << Id );
                    taint = UNSAFE_TAG;
                    setTag(CurrentGContext, Id, taint);
                    LLVMContext &VMCtx = I->getContext();
                    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,"unsafe"));
                    I->setMetadata(MD_STATE,MD);
                }

                break;
            case Instruction::ICmp:
//                taint = getTaint(I->getOperand(0),currentTF) > taint ? getTaint(I->getOperand(0),currentTF) : taint;
//                taint = getTaint(I->getOperand(1),currentTF) > taint ? getTaint(I->getOperand(0),currentTF) : taint;
//                break;
            case Instruction::FCmp:
            case Instruction::Switch:
            case Instruction::Br:
            case Instruction::IndirectBr:
                break;
            default:
                for (User::op_iterator OI = I->op_begin(), OE = I->op_end();
                     OI != OE; ++OI) {
                    taint = getTaint(*OI,currentTF) > taint ? getTaint(*OI,currentTF) : taint;
                }
                break;
        }

        if (taint==UNSAFE_TAG && !MD) {
            STA_DEBUG("taint instruction = " << *I );
            changed |= setTaint(I, currentTF);
        }
    }

    //then we should find the taint state of args
    for(Argument &A : F.args()){
        unsigned index = A.getArgNo();
        if(getTaint(&A,currentTF)==UNSAFE_TAG){
            currentTF->propagateOut += (1<<index);
        }
    }

    return changed;
}

void UnSafeOBjects::propagateUnSafeTags(Function &F, SmallVector<std::pair<Instruction *, Value *>, 32> &Worklist,
                                        DenseSet<std::pair<Instruction *, Value *>> &VisitedPHINodes) {
    SmallSet<Instruction*,8> pointerSubUncertainSet;
    while(!Worklist.empty()){
        const auto &it = Worklist.pop_back_val();
        Instruction *instruction = it.first;
        Value *Ptr = it.second;

        switch (instruction->getOpcode()){
            case Instruction::Store:
                checkGlobalPointerStore(F,instruction);
            case Instruction::Load:{
                setPropagation(&F,instruction);
                continue;
            }
            case Instruction::Call:
            case Instruction::Invoke:{
                //here we need to propogate the called Function's argument
                instrumentCall(&F,instruction,Ptr);
                continue;
            }
            case Instruction::PHI:{
                setPropagation(&F,instruction);
                VisitedPHINodes.insert(it);
                break;
            }
            case Instruction::ICmp:
                assert(instruction->getType()->isIntegerTy() && "Icmp need to be tracked");
            case Instruction::Br:
            case Instruction::Trunc:
            case Instruction::Mul:
            case Instruction::AShr:
            case Instruction::LShr:
                continue;
            case Instruction::GetElementPtr:
            case Instruction::IntToPtr:
            case Instruction::BitCast:
            case Instruction::PtrToInt:
            case Instruction::Select:
            case Instruction::Add:
            case Instruction::And:
                setPropagation(&F,instruction);
                break;
            case Instruction::Sub:
                pointerSubUncertainSet.insert(instruction);
                break;
            case Instruction::Ret:
                instrumentRet(&F,instruction);
                continue;

            default:
                setPropagation(&F,instruction);
                errs()<<"We miss: ";instruction->print(errs());errs()<<"\n";
                break;
        }

        for(User *UU: instruction->users()){
            auto P = std::make_pair(cast<Instruction>(UU),instruction);
            if(needsPropagation(&F,dyn_cast<Instruction>(UU)) && !VisitedPHINodes.count(P)){
                Worklist.push_back(P);
            }
        }
    }

    //then we check the pointerSubUncertainSet
    for(auto itr:pointerSubUncertainSet){
        assert(itr->getOpcode()==Instruction::Sub && "its is not a sub instruction");
        Instruction *oper0 = dyn_cast<Instruction>(itr->getOperand(0));
        Instruction *oper1 = dyn_cast<Instruction>(itr->getOperand(1));
        if(needsPropagation(&F,oper0) && needsPropagation(&F,oper1)){
            //ignore pointer sub pointer
        } else{
            for(User *UU: itr->users()){
                auto P = std::make_pair(cast<Instruction>(UU),itr);
                if(needsPropagation(&F,dyn_cast<Instruction>(UU)) && !VisitedPHINodes.count(P)){
                    Worklist.push_back(P);
                }
            }
        }
    }
}
bool UnSafeOBjects::runOnModule(Module &M) {
    bool changed = false, ret = false;

    errs()<<"\n===================start to run Module=======================\n";

    for(Function &F:M){
        if(CurrentTContext.count(&F))
            continue;
        reset(&F);
        changed|=runOnFunction(F, nullptr);
    }

//    while (!functionNeedUpdate.empty()){
//        Function *function = dyn_cast<Function>(*functionNeedUpdate.begin());
//        functionNeedUpdate.erase(function);
//        if(!shouldInstrument(function)) continue;
//
//        reset(function);
//        changed|=runOnFunction(*function,true);
//    }

    ret |= changed;
    return ret;
}


bool UnSafeOBjects::runOnFunction(Function &F,struct TracedFunction * tf) {
    bool changed = true, ret = false;
    if (F.isIntrinsic())
        return false;

    struct TracedFunction* currentTF = tf;
    STA_DEBUG("start run function ==== " << F.getName() );
    if(!currentTF){
        currentTF = new TracedFunction();
        currentTF->func = &F;
        currentTF->argTaintedState= 0;
        //we taint all args here
        for(Argument &A : F.args()){
            if(A.getType()->isPointerTy()){
                unsigned index = A.getArgNo();
                currentTF->argTaintedState |= (1<<index);
            }
        }

        currentTF->propagateOut = 0;
        currentTF->retTainted = false;
        CurrentTContext[&F].push_back(currentTF);
    }

    isSpecialFunctionToTaint(&F,currentTF->argTaintedState);

    //taint arguments
    if(currentTF->argTaintedState){
        int argNum=0;
        for(Argument &A : F.args()){
            unsigned index = A.getArgNo();
            if(currentTF->argTaintedState & (1<<index)){
                std::string Id = getArgId(&A);
                STA_DEBUG("taint unsafe argument " << A << ", Id = " << Id );
                setTaint(&A,currentTF);
            }
            argNum++;
        }
        if(F.isVarArg()){
            if(currentTF->argTaintedState & 1<<(argNum-1)){
                Argument &theLastArg = *(F.arg_begin()+(argNum-1));
                setTaint(&theLastArg,currentTF);
            }
        }
    }

    //taint unsafe mallocs in this function;
    if(UnSafeMallocInst.count(&F)){
        for(auto itr:UnSafeMallocInst[&F]){
            setTaint(itr.first,currentTF);
        }
    }

    while(changed){
        changed = false;
        changed |= forwardTaint(F, currentTF);

        if(changed)
            STA_DEBUG( " Function "<< F.getName()<< "changed");
        ret |= changed;
    }

    return ret;
}

bool UnSafeOBjects::propagateInFunction(Function *F, bool checkerCaller) {
//    bool changed = true, ret = false;
//
//    if (F->isIntrinsic())
//        return false;
//
//    assert(!F->isDeclaration() && "function is Declaration");
//
//    //taint arguments
//    for (Argument &A : F->args()) {
//        std::string Id = getStructId(A.getType(), CurrentModule);
//        if (!Id.empty()) {
//            STA_DEBUG("taint sensitive argument " << A << ", Id = " << Id);
//            setTaint(&A, SAFE_TAG);
//        }
//    }
//
//    while(changed){
//        changed = false;
//        changed |= forwardTaint(*F,checkerCaller);
//        ret |= changed;
//    }
//
//
////    if(checkerCaller)
////        taintCaller(*F);

}

void UnSafeOBjects::propagateUnSafeTags(Function &F) {
    SmallVector<std::pair<Instruction*, Value*>, 32> Worklist;
    //1. gather the sinks, and init worklist
    SmallVector<Value*,32> sinks;
    //1.1 arguments
    if(!F.arg_empty()){
        auto temp1= unSafeArgment.find(&F);
        if(temp1!=unSafeArgment.end()){
            for(auto itr:*temp1->second){
                sinks.push_back(F.arg_begin()+itr);
//                (F.arg_begin()+itr)->print(errs());errs()<<F.arg_size()<<" arg "<< itr<<"\n";
            }
        }
    }

    auto temp = unSafeAllocations.find(&F);
    if(temp!=unSafeAllocations.end()){
        for(auto itr:*temp->second){
            sinks.push_back(itr);
        }
    }

    while (!sinks.empty()){
        auto itrS = sinks.pop_back_val();
        for(User *U : itrS->users()){
            ifncast(Instruction,UI,U){
                sinks.push_back(U);
                continue;
            }
            Worklist.push_back(std::make_pair(UI,itrS));
        }
    }


    //2. clear the propagating set
    auto temp2 = unSafePropagation.find(&F);
    if(temp2!= unSafePropagation.end()){
        temp2->second->clear();
    }else{
        auto *newset = new DenseSet<Instruction*>();
        unSafePropagation.insert(std::make_pair(&F,newset));
    }

    //3. start to propagating
    DenseSet<std::pair<Instruction*, Value*>> VisitedPHINodes;
    while (!Worklist.empty()){
        propagateUnSafeTags(F,Worklist,VisitedPHINodes);
    }
}

//bool UnSafeOBjects::isUnSafe(Function *function,Value *Allocation) {
//    auto it = unSafeAllocations.find(function);
//    if(it==unSafeAllocations.end()){
//        return false;
//    }
//    return it->second->count(Allocation);
//}

void UnSafeOBjects::setUnsafe(Function *function,Value *Allocation) {
    auto it = unSafeAllocations.find(function);
    if(it==unSafeAllocations.end()){
        auto *newset = new DenseSet<Value*>();
        newset->insert(Allocation);
        unSafeAllocations.insert(std::make_pair(function,newset));
    } else{
        it->second->insert(Allocation);
    }

}
bool UnSafeOBjects::isUnSafeSource(Function *F,Value *value) {

    if(isa<Instruction>(value)){
        if(CallInst *ci = dyn_cast<CallInst>(value)) {
            assert((F == ci->getFunction()) && "value and function are not the same");
            if (UnSafeMallocInst.count(F) && UnSafeMallocInst[F].count(ci)) {
                return true;
            }
        }else{

        }
    }else{
        std::string Id = getAnnotation(value,CurrentModule);
//        if(UnSafeGlobalVariable.count(Id)){
//            return true;
//        }
    }
    return false;
}

void UnSafeOBjects::findUnSafeAllocation(Function &F) {
    AllocationSite AS;
//    std::string Id;
    assert( (SE!= nullptr)  && "SE is nullptr");
    const SCEV *Boundary = SE->getConstant(Type::getInt64Ty(F.getContext()),BLOCKSIZE);
    for (Instruction &I : instructions(F)) {
        if(!isAllocation(&I,AS))
            continue;

        const SCEV *size = AS.getSizeSCEV(*SE);
        //compare the malloc size with Boundary
        if(isNotDerefecencedBeyondBoundary(&I,size,Boundary)){
            continue;
        }

        STA_DEBUG("find unsafe malloc"<< I);
//        size->print(errs());errs()<<"\n";

        std::string loc;
        raw_string_ostream rso(loc);
        size->print(rso);
        errs()<<rso.str()<<"\n";

        if(UnSafeMallocInst.count(&F)){
            UnSafeMallocInst[&F].insert(std::make_pair(&I,rso.str()));
        }else{
            std::unordered_map<Instruction*, std::string> map;
            map.insert(std::make_pair(&I,rso.str()));
            UnSafeMallocInst.insert(std::make_pair(&F,map));
        }


//        if(UnSafeMallocInst.count(&F)){
//            UnSafeMallocInst[&F][&I]=size;
//        } else{
//            std::unordered_set<Value*> D;
//            D.insert(&I);
//            UnSafeMallocInst.insert(std::make_pair(&F,D));
//        }

    }

//    //check the user of GEP to find exceptions
//    for (Instruction &I : instructions(F)) {
//        ifncast(GetElementPtrInst,GEP,&I)
//            continue;
//        Value *Base=GEP->getPointerOperand();
//        const SCEV *Offset = SE->getMinusSCEV(SE->getSCEV(GEP), SE->getSCEV(Base));
//        ICmpInst::Predicate pred=ICmpInst::ICMP_ULE;
//
//        const SCEV *blockBoundary=SE->getConstant(Type::getInt64Ty(F.getContext()),BLOCKSIZE);
//
//        SE->SimplifyICmpOperands(pred,Offset,blockBoundary);
//
//        bool result = SE->isKnownPredicate(pred,Offset,blockBoundary);
////        Offset->print(errs()); errs()<<"result: "<<result<<" offset SECV\n";
//        if(!result){
//            setUnsafe(&F,&I);
//            setTaint(I,UNSAFE_TAG);
//        }
//    }

    //we use a conservative scheme:
    // we will taint any load Instruction that loads an object bigger than a shadow page or size that are unknown
//    const DataLayout &DL = F.getParent()->getDataLayout();
//    for (Instruction &I : instructions(F)) {
//        ifncast(LoadInst,loadI,&I)
//            continue;
//
//        Type *Ty=loadI->getPointerOperandType()->getPointerElementType();
//        if(Ty->isPointerTy()){
//            Ty=Ty->getPointerElementType();
//            if(Ty->isPointerTy())
//                continue;
//        }
//
//        if(Ty->isSized()){
//            uint64_t size =DL.getTypeSizeInBits(Ty);
//            if(size>0x7c0){
////                loadI->print(errs());errs()<<"\n";
////                Ty->print(errs());
////                errs()<<" storeSize "<<size<<"\n";
////                setUnsafe(&F,&I);
//            }
//        }
//
//    }
}

void UnSafeOBjects::findUnSafeGlobals(Module &M) {
    std::string Id;
    assert((SE!= nullptr) && "SE is null");
    BlockBoundary = SE->getConstant(Type::getInt64Ty(M.getContext()),BLOCKSIZE);
    //find globals that are bigger than boundary and insert into CurrentGContext
    for(GlobalVariable &GV:M.globals()){
        const SCEV *size = getGlobalSizeSCEV(&GV,*SE);
        if(isNotDerefecencedBeyondBoundary(&GV,size,BlockBoundary)){
            continue;
        }

        Id = getAnnotation(&GV,&M);
        if(setTag(CurrentGContext,Id,UNSAFE_TAG)){
            STA_DEBUG("setTaint CurrentGContext ID = "<< Id << "; value = "<<GV);
        }
    }
    return;
}

void
UnSafeOBjects::findUnSafeGEPs(Function &F, DenseMap<Value *, std::pair<const SCEV *, const SCEV *>> &PointerBounds) {

    for(Instruction &I : instructions(F)){
        ifncast(GetElementPtrInst,GEP,&I)continue;

        // See if the distance to the end of the object was propagated by
        // propagateAllocationOffset
        auto it = PointerBounds.find(GEP);
        if (it == PointerBounds.end()){
            continue;
        }

        const SCEV *Size = it->second.first;
//        const SCEV *Offset = it->second.second;
//
//        // Some GEPs in loops use the induction variable, causing SCEV analysis
//        // to think that the maximum value of the pointer is the value *after*
//        // the loop, which is usually a pointer to the end of the object (which
//        // is OOB). We detect the pattern where the induction variable is
//        // compared to a loop exit value before ever being dereferenced, and
//        // ignore the last iteration in the distance calculation.
//        InductionDescriptor D;
//        if(isNotDereferencedInLastLoopIteration(GEP,D)){
//            if(D.getConsecutiveDirection()==1){
//                //i+=step
//                const SCEV *Step = SE->getConstant(D.getConstIntStepValue());
//                Offset = SE->getAddExpr(Offset,Step);
//            }else {
//                errs() << __func__ << " we find D.getConsecutiveDirection()==-1\n";
//            }
//        }
//
//        // For a GEP in an incrementing for-loop, we only need to check the
//        // value after (or in, see above) the last iteration.
//        ifcast(const SCEVAddRecExpr, AR, Offset) {
//            if (SE->isKnownNegative(AR->getStepRecurrence(*SE))) {
//                Offset = SE->getSCEVAtScope(AR, AR->getLoop()->getParentLoop());
//                errs()<<"max distance in loop: " << *Offset<<"\n";
//            }else if (SE->isKnownPositive(AR->getStepRecurrence(*SE))) {
//                Offset = SE->getSCEVAtScope(AR, AR->getLoop()->getParentLoop());
//                // TODO: get value at first iteration
//                errs()<<"max distance in loop: Positive" << *Offset<<"\n";
//            }
//        }
//
////        errs()<<" isNotDerefecencedBeyondBoundary:\n";
////        errs()<<" Offset "; Offset->print(errs());errs()<<"\n";
////        errs()<<" BlockBoundary "; BlockBoundary->print(errs());errs()<<"\n";
//
//        //then we need to prove that the offset is larger than the
//        //a block
//        if(isNotDerefecencedBeyondBoundary(GEP,Offset,BlockBoundary))
//            continue;

        if(isNotDerefecencedBeyondBoundary(GEP, Size, BlockBoundary))
            continue;
        setPropagation(&F,GEP);
    }
}

void UnSafeOBjects::setPropagation(Function *function,Instruction *instruction) {

    auto it = unSafePropagation.find(function);
    if(it==unSafePropagation.end()){
        auto *newset = new DenseSet<Instruction*>();
        newset->insert(instruction);
        unSafePropagation.insert(std::make_pair(function,newset));
    } else{
        it->second->insert(instruction);
    }

}

bool UnSafeOBjects::isNotDerefecencedBeyondBoundary(Value *Ptr, const SCEV *Offset, const SCEV *Boundary) {
    //check whether Offset is a constant
    // if is true, Offset is a constant
    // otherwise, it is not
    if(compareSCEVs(ICmpInst::ICMP_SGE,Offset,trickyOne)){
        return !compareSCEVs(ICmpInst::ICMP_SGE,Offset,Boundary);
    } else{
        return false;
    }

//    SmallVector<const SCEV*,8> DerefBytes;
//
//    errs()<<"================isNotDerefecencedBeyondBoundary start\n";
//    Offset->print(errs());errs()<<"\n";
//    Ptr->print(errs());errs()<<"\n";
//
//    if(!findAllDereferencedBytes(Ptr,DerefBytes))
//        return false;
//
//    for(const SCEV *NBytes :DerefBytes){
//        errs()<<"NBytes:";NBytes->print(errs());errs()<<" "; NBytes->getType()->print(errs());errs()<<"\n";
//        errs()<<"Boundary:";Boundary->print(errs());errs()<<" ";Boundary->getType()->print(errs());errs()<<"\n";
//        if(compareSCEVs(ICmpInst::ICMP_SGE,NBytes,Boundary))
//            return false;
//    }
//    return true;
}

bool UnSafeOBjects::compareSCEVs(ICmpInst::Predicate Pred, const SCEV *LHS, const SCEV *RHS) {
    SE->SimplifyICmpOperands(Pred,LHS,RHS);
    bool Result = SE->isKnownPredicate(Pred,LHS,RHS);
    return Result;
}

bool UnSafeOBjects::findAllDereferencedBytes(Value *ptr, SmallVectorImpl<const SCEV *> &DerefBytes) {
    struct Entry{
        Value *I;
        Instruction *UI;
        const SCEV *Offset;
    };

    SmallVector<struct Entry, 8> Worklist;
    SmallPtrSet<PHINode *,4> VisitedPHINodes;

    for(User *U : ptr->users()){
        ifcast(Instruction,UI,U)
            Worklist.push_back({ptr,UI, nullptr});
    }

    while (!Worklist.empty()){
        const struct Entry &E = Worklist.pop_back_val();
        const SCEV *UOffset = E.Offset;

        switch (E.UI->getOpcode()){
//            case Instruction::ICmp:
//                assert(!E.UI->getType()->isPointerTy());
//                continue;
//            case Instruction::Select:
//                //the value of offset here is not accurate.
//                return  false;

            case Instruction::Load:
                DerefBytes.push_back(addSCEVs(E.Offset,getSizeOfSCEV(E.UI->getType())));
                continue;
            case Instruction::Store:
                if(E.UI->getOperand(0)==E.I)
                    return false;
                DerefBytes.push_back(addSCEVs(E.Offset,getSizeOfSCEV(E.UI->getOperand(0)->getType())));
                continue;
            case Instruction::PHI:
                //Avoid recursing cyclic phi references
                if(VisitedPHINodes.count(cast<PHINode>(E.UI)))
                    continue;
                VisitedPHINodes.insert(cast<PHINode>(E.UI));
                break;
            case Instruction::Call:
                continue;
            case Instruction::Invoke:
                return false;

            case Instruction::GetElementPtr:
                //if break on unsafeGEP since they are already proven to to be unsafe
                //if they are already taged, we don't need to propagate them again.
                if(needsPropagation(E.UI->getParent()->getParent(),cast<GetElementPtrInst>(E.UI)))
                    continue;
                //fallthrough
            default:
                if(const SCEV *PtrOffset = getPointerCastOrArithOffset(E.UI,E.I)){
                    if(PtrOffset->isZero()){
                        //if PtrOffset is zero, we donot need to update the UOffset.
                    }else{
                        UOffset = addSCEVs(UOffset,PtrOffset);
                    }
                    break;
                }

                return false;
        }
        for(User *U : E.UI->users())
            Worklist.push_back({E.UI,cast<Instruction>(U),UOffset});
    }
    return true;
}

bool UnSafeOBjects::needsPropagation(Function *function,Instruction *instruction) {

    auto it = unSafePropagation.find(function);

    if(it==unSafePropagation.end()){
        return false;
    }
    return !it->second->count(instruction);
}

static Value *getComparedLoopExitValue(const Loop *L, Value *V, BranchInst *&Br) {
    if (!L->hasDedicatedExits())
        return nullptr;

    Br = dyn_cast<BranchInst>(L->getHeader()->getTerminator());

    if (!Br || Br->isUnconditional())
        return nullptr;

    ifncast(ICmpInst, Cmp, Br->getCondition())
        return nullptr;

    if (Cmp->getPredicate() != ICmpInst::ICMP_EQ)
        return nullptr;

    if (L->contains(Br->getSuccessor(0)) || !L->contains(Br->getSuccessor(1)))
        return nullptr;

    if (Cmp->getOperand(0) == V)
        return Cmp->getOperand(1);
    else if (Cmp->getOperand(1) == V)
        return Cmp->getOperand(0);

    return nullptr;
}


bool UnSafeOBjects::isNotDereferencedInLastLoopIteration(GetElementPtrInst *GEP, InductionDescriptor &D) {
    // If the pointer is a GEP in a loop ...
    const SCEV *SC = SE->getSCEV(GEP);

    ifncast(const SCEVAddRecExpr, AR, SC)
        return false;

    const Loop *L = AR->getLoop();
    // and all users are loads/stores within the loop ...
    SmallVector<Instruction*, 4> Derefs;
    for (User *U : GEP->users()) {
        ifcast(LoadInst, LI, U) {
            Derefs.push_back(LI);
        }
        else ifcast(StoreInst, SI, U) {
            if (SI->getValueOperand() == GEP)
                return false;
            Derefs.push_back(LI);
        }
        else {
            return false;
        }
    }

    // ... and it is based on the loop induction variable ...
    if (GEP->getNumOperands() != 2)
        return false;

    ifncast(PHINode, PN, GEP->getOperand(1))
        return false;

    assert(AR->getLoop()->getLoopPreheader());
    if (!InductionDescriptor::isInductionPHI(PN, L, SE, D))
        return false;

    // ... which determines the exit condition of the loop ...
    BranchInst *Br;
    Value *ComparedExitValue = getComparedLoopExitValue(L, PN, Br);
    if (!ComparedExitValue)
        return false;

    const SCEV *ExitExpr = SE->getSCEVAtScope(AR, L->getParentLoop());

    // ... and the branch dominates all loads/stores ...
    for (Instruction *Deref : Derefs) {
        if (!DT->dominates(Br, Deref)) {
//            DEBUG_LINE("not dominated:" << *Deref);
//            DEBUG_LINE("           by:" << *Br);
            return false;
        }
    }

    // ... then the pointer is never dereferenced in the last iteration
    return true;
}

const SCEV *UnSafeOBjects::getSizeOfSCEV(Type *Ty) {
    return SE->getSizeOfExpr(Type::getInt64Ty(Ty->getContext()),Ty);
}

//in this function, we would propagate the heap allocation and the global,
//we record the the (Instrucntion, (totalSize, currentOffset))
void UnSafeOBjects::propagateAllocationOffet(Function &F, DenseMap<Value *, std::pair<const SCEV*,const SCEV*>> &PointerBounds) {
    SmallVector<std::pair<Instruction*,std::pair<const SCEV*,const SCEV*>>,16> Worklist;
    const SCEV *ZeroSCEV = SE->getZero(Type::getInt64PtrTy(F.getContext()));

    for(Instruction &I :instructions(F)){
        AllocationSite AS;
        //find the big allocation
        if(isAllocation(&I,AS)){
            if(compareSCEVs(ICmpInst::ICMP_SGE, AS.getSizeSCEV(*SE), BlockBoundary)){
                Worklist.push_back(std::make_pair(&I, std::make_pair(AS.getSizeSCEV(*SE),
                                                                     ZeroSCEV)));
            }

        }else if(I.getNumOperands()>0){
            ifncast(GlobalVariable, GV, I.getOperand(0))
                continue;

            const SCEV *Size = getGlobalSizeSCEV(GV,*SE);

            if(!compareSCEVs(ICmpInst::ICMP_SGE, Size, BlockBoundary)){
                continue;
            }

            switch (I.getOpcode()){
                case Instruction::BitCast:
                case Instruction::PtrToInt:
                case Instruction::IntToPtr:
                    Worklist.push_back(std::make_pair(&I,std::make_pair(Size,ZeroSCEV)));
                    break;
                case Instruction::GetElementPtr:
                    Worklist.push_back(std::make_pair(&I,std::make_pair(Size,getGEPOffsetSCEV(cast<GetElementPtrInst>(&I)))));
                case Instruction::Call:
                case Instruction::Invoke:
                    break;
                default:
                    break;
            }
        }
    }

    while (!Worklist.empty()) {
        const auto &P = Worklist.pop_back_val();
        Instruction *I = P.first;
        const SCEV *DistSize = P.second.first;
        const SCEV *Offset = P.second.second;

        assert(PointerBounds.count(I) == 0);
        PointerBounds[I] = std::make_pair(DistSize,Offset);

        for (User *U : I->users()) {
            Instruction *UI = cast<Instruction>(U);
            const SCEV *UDist = nullptr;

            switch (UI->getOpcode()) {
                case Instruction::Call:
                case Instruction::Invoke:
                    break;
                case Instruction::ICmp:
                case Instruction::Load:
                case Instruction::Store:
                case Instruction::Ret:
                    break;
                default:
                    const SCEV *newOffset = getPointerCastOrArithOffset(UI, I);
                    if (newOffset) {
                        UDist = newOffset->isZero() ? Offset : SE->getAddExpr(Offset, newOffset);
                    } else{
                        errs()<<"12 unsupported for tracking:"<< *UI;errs()<<"\n";
                        errs()<<"12                       of:"<< *I;errs()<<"\n";
                        assert(newOffset);

                    }
                    break;
            }
            if(UDist)
                Worklist.push_back(std::make_pair(UI,std::make_pair(DistSize,UDist)));
        }
    }
}

const SCEV *UnSafeOBjects::getPointerCastOrArithOffset(Instruction *I, Value *value) {
    switch (I->getOpcode()){
        //if it is a cast, we only need to pass the prev SEV here.
        case Instruction::BitCast:
        case Instruction::PtrToInt:
        case Instruction::IntToPtr:
            return SE->getZero(Type::getInt64PtrTy(I->getContext()));

        //if it is a ArithOffset, we need to update the SEV with the new offset.
        case Instruction::GetElementPtr:
//            GetElementPtrInst *getElementPtrInst = dyn_cast<GetElementPtrInst>(I);
            return getGEPOffsetSCEV(dyn_cast<GetElementPtrInst>(I));
        case Instruction::Add:
            return SE->getSCEV(otherOperand(I,value));
        case Instruction::Sub:
            if (I->getOperand(0) == value)
                return SE->getNegativeSCEV(SE->getSCEV(I->getOperand(1)));
            break;
        case Instruction::And:
            return SE->getMinusSCEV(SE->getSCEV(I),SE->getSCEV(value));
        default:
            break;
    }
    return nullptr;
}

const SCEV *UnSafeOBjects::getGEPOffsetSCEV(GetElementPtrInst *getElementPtrInst, bool NoWrap) {
    Value *Base = getElementPtrInst->getPointerOperand();
    const SCEV *Offset = SE->getMinusSCEV(SE->getSCEV(getElementPtrInst), SE->getSCEV(Base));

    return Offset;
}

const SCEV *UnSafeOBjects::addSCEVs(const SCEV *LHS, const SCEV *RHS) {
    if(!LHS){
        assert(RHS);
        return  RHS;
    }
    if(!RHS){
        assert(LHS);
        return  LHS;
    }

    return SE->getAddExpr(LHS,RHS);
}



