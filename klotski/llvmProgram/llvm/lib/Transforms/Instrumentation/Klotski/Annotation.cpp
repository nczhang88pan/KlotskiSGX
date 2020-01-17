//
// Created by alax on 7/13/18.
//

#include <llvm/Support/raw_ostream.h>
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Instructions.h"

#include "Annotation.h"
#include "Allocation.h"

using namespace llvm;

//get the annotation of pointer
std::string getStoreId(StoreInst *SI,SpecialMIMapType *miMap,struct TracedFunction * currentTF){
    //if this instruction has been handled.
    StringRef Id=getLoadStoreId(SI);
    if(!Id.empty()){
        return Id.str();
    }

    //otherwise,
    std::string Anno;
    LLVMContext &VMCtx = SI->getContext();
    Module *M = SI->getModule();
    Value *V = SI->getPointerOperand();
    Anno = getAnnotation(V,M,miMap,currentTF);

    if(Anno.empty())
        return Anno;

    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,Anno));
    SI->setMetadata(MD_ID,MD);
    return Anno;
}

//get load pointer's MD_ID metadata
std::string getLoadId(LoadInst *LI,SpecialMIMapType *miMap,struct TracedFunction * currentTF){
    //check if this load has MD_ID metadata.
    StringRef Id = getLoadStoreId(LI);
    if(!Id.empty())
        return Id.str();

    //get the pointer's annotation
    std::string Anno;
    LLVMContext &VMCtx = LI->getContext();
    Module *M = LI->getModule();
    Value *V = LI->getPointerOperand();
    Anno = getAnnotation(V,M,miMap,currentTF);
    if(Anno.empty())
        return Anno;

    //set the MD_ID meta data
    MDNode *MD = MDNode::get(VMCtx,MDString::get(VMCtx,Anno));
    LI->setMetadata(MD_ID,MD);
    return Anno;
}
std::string getAnonStructId(Value *V, Module *M, StringRef Prefix) {
    //TODO
    SmallPtrSet<Value*, 4> Visited;
    SmallVector<Value*, 4> WorkList;
    Visited.insert(V);
    WorkList.push_back(V);

    while(!WorkList.empty()){
        Value *v = WorkList.pop_back_val();

        //only handle GEP and cast
        User::op_iterator is, ie; // GEP indices
        Value *PVal = NULL;       // Pointer operand in the GEP
        if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(v)) {
            // GEP instruction
            is = GEP->idx_begin();
            ie = GEP->idx_end() - 1;
            PVal = GEP->getPointerOperand();
        } else if (ConstantExpr *CE = dyn_cast<ConstantExpr>(v)) {
            // constant GEP expression
            if (CE->getOpcode() == Instruction::GetElementPtr) {
                is = CE->op_begin() + 1;
                ie = CE->op_end() - 1;
                PVal = CE->getOperand(0);
            } else if (CE->isCast()) {
                if (Visited.insert(CE->getOperand(0)).second)
                    WorkList.push_back(CE->getOperand(0));
                continue;
            }
        }

        // id is in the form of struct.[name].[offset]
        if (PVal) {
            // prefer global over struct
            if (GlobalValue *GV = dyn_cast<GlobalValue>(PVal)) {
                return getVarId(GV);
            }

            std::string structId = getStructId(PVal, is, ie, M);
            if (!structId.empty())
                return structId;
        }

        if (CastInst *CI = dyn_cast<CastInst>(v)) {
            if (Visited.insert(CI->getOperand(0)).second)
                WorkList.push_back(CI->getOperand(0));
            continue;
        }

        break;
    }
    return Prefix;
}

std::string getStructId(Value *PVal, User::op_iterator &IS, User::op_iterator &IE, Module *M){
    Type *PTy = PVal->getType();
    StructType *STy = nullptr;
    //get struct type
    for(++IE;IS!=IE;++IS){
        CompositeType *CT = dyn_cast<CompositeType>(PTy);
        if(!CT) break;
        if((STy = dyn_cast<StructType>(CT))) break;
        if(!CT->indexValid(*IS)) break;
        PTy = CT->getTypeAtIndex(*IS);
    }

    if(STy && !STy->isOpaque() && !STy->isLiteral()){
        std::string out;
        raw_string_ostream rso(out);

        std::string structName = STy->getStructName().str();
        if(structName.find("struct.anon")==0){
            structName = getScopeName(STy,M);
            structName = getAnonStructId(PVal,M,structName);
        }

        rso<<structName;
        for(;IS!=IE;++IS){
            rso<<",";
            ConstantInt *Idx = dyn_cast<ConstantInt>(*IS);
            if(Idx)
                rso<<Idx->getZExtValue();
            else
                (*IS)->printAsOperand(rso); //TODO: Klotskik,
        }
        return rso.str();
    }
    return "";
}

//this function does a backward analysis to get the Annotation
std::string getAnnotation(Value *V,Module* M,SpecialMIMapType *miMap,struct TracedFunction * currentTF){
    SmallPtrSet<Value*,16> Visited;
    SmallVector<Value*,8> WorkList;

    Visited.insert(V);
    WorkList.push_back(V);

    while (!WorkList.empty()){
        Value *v = WorkList.pop_back_val();

        if(GlobalVariable *GV = dyn_cast<GlobalVariable>(v))
            return getVarId(GV);

        if(Argument *A = dyn_cast<Argument>(v))
            return getArgId(A);

        User::op_iterator is,ie;//GEP indices
        Value *PVal = NULL;
        if(GetElementPtrInst *GEP=dyn_cast<GetElementPtrInst>(v)){
            //GEP instruction
            is = GEP->idx_begin();
            ie = GEP->idx_end() - 1;
            PVal = GEP->getPointerOperand();
        }else if(ConstantExpr *CE = dyn_cast<ConstantExpr>(v)){
            // constant GEP expression
            if(CE->getOpcode() == Instruction::GetElementPtr){
                is = CE->op_begin()+1;
                ie = CE->op_end() -1;
                PVal = CE->getOperand(0);
            }else if (CE->isCast()){
                if (Visited.insert(CE->getOperand(0)).second){
                    //never visited
                    WorkList.push_back(CE->getOperand(0));
                }
                continue;
            }
        }

        //id is in the form of struct.[name].[offset]
        if(PVal){
            std::string structID = getStructId(PVal,is,ie,M);
            if(!structID.empty()){
                return structID;
            }else {
                if(Visited.insert(PVal).second)
                    WorkList.push_back(PVal);
                continue;
            }
        }

        if(AllocaInst *AI = dyn_cast<AllocaInst>(v)){
            return getVarId(AI);
        }

        if(CastInst *CI = dyn_cast<CastInst>(v)){
            if(Visited.insert((CI->getOperand(0))).second)
                WorkList.push_back(CI->getOperand(0));
            continue;
        }

        if(CallInst *CI = dyn_cast<CallInst>(v)){
            Value *CV = CI->getCalledValue();
            if(ConstantExpr *CE = dyn_cast<ConstantExpr>(CV)){
                if(CE->isCast())
                    CV=CE->getOperand(0);
            }

            Function *calledFunc=dyn_cast<Function>(CV);
            Function *parentFunc=CI->getFunction();
            if(calledFunc!=NULL){
                // check for alloc function
                AllocationSite AS;
                std::string id = getRetId(calledFunc);
                if(isAllocation(CI,AS)){
                    if(miMap && miMap->count(parentFunc)){
                        if((*miMap)[parentFunc].count(CI)){
                            //[value].[SECV].[parentFunction]
                            std::string str = (*miMap)[parentFunc][CI];
                            id+="."+ str +".";
                            id+=parentFunc->getName();
                        }
                    }
                }
                return id;
            }
        }

        if(LoadInst *LI = dyn_cast<LoadInst>(v)){
            Value *S = LI->getPointerOperand();
            if(Visited.insert(S).second)
                WorkList.push_back(S);
            continue;
        }

        if(PHINode *PHI = dyn_cast<PHINode>(v)){
            for(unsigned i=0, e=PHI->getNumIncomingValues();i<e;++i){
                if(Visited.insert(PHI->getIncomingValue(i)).second){
                    WorkList.push_back(PHI->getIncomingValue(i));
                }
            }
            continue;
        }

        if(SelectInst *SEI = dyn_cast<SelectInst>(v)){
            if(Visited.insert(SEI->getTrueValue()).second)
                WorkList.push_back(SEI->getTrueValue());
            if(Visited.insert(SEI->getFalseValue()).second)
                WorkList.push_back(SEI->getFalseValue());
            continue;
        }

        if(BinaryOperator *BO = dyn_cast<BinaryOperator>(v)){
            //only when one of the operand is a constant int
            if(isa<ConstantInt>(BO->getOperand(1))){
                if(Visited.insert(BO->getOperand(0)).second)
                    WorkList.push_back(BO->getOperand(0));
                continue;
            }
            if(isa<ConstantInt>(BO->getOperand(0))){
                if(Visited.insert(BO->getOperand(1)).second)
                    WorkList.push_back(BO->getOperand(1));
                continue;
            }
        }

    }

    return std::string();
}