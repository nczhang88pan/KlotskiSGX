//
// Created by alax on 6/8/18.
//

#include "Allocation.h"
#include <llvm/IR/Function.h>

using namespace llvm;

static inline bool isInList(std::map<std::string, int> Map, Function *F) {
    return Map.find(F->getName().str()) != Map.end();
}

static inline bool isInList(std::set<std::string> Set, Function *F) {
    return Set.count(F->getName().str()) > 0;
}

static std::map<std::string, int> MallocFuncs = {
        { "malloc", 0 },
};

static std::map<std::string, int> MallocWrappers = {
};
static std::set<std::string> IgnoreFuncs = {
//        "sprintf","snprintf"
};

static std::map<std::string, int> MalignFuncs = {
        { "memalign",1},
};

static std::set<std::string> CallocFuncs = {
        "calloc",
};

static std::set<std::string> CallocWrappers = {
};

static std::set<std::string> ReallocFuncs = {
        "realloc",
};

static std::set<std::string> ReallocWrappers = {
};

static std::set<std::string> FreeFuncs = {
        "free",
};

static std::set<std::string> FreeWrappers = {
};

bool functionShouldBeIgnored(Function *F){
    return isInList(IgnoreFuncs, F);
}
bool isMalign(Function *F,int argNum) {
    return isInList(MalignFuncs, F) && (argNum==2);
}

bool isMalloc(Function *F,int argNum) {
    return isInList(MallocFuncs, F) && (argNum==1);
}

bool isCalloc(Function *F,int argNum) {
    return isInList(CallocFuncs, F)&& (argNum==2);
}

bool isRealloc(Function *F,int argNum) {
    return isInList(ReallocFuncs, F)&& (argNum==2);
}

bool isFree(Function *F) {
    return isInList(FreeFuncs, F);
}

bool isMallocWrapper(Function *F) {
    return isInList(MallocWrappers, F);
}

bool isCallocWrapper(Function *F) {
    return isInList(CallocWrappers, F);
}

bool isReallocWrapper(Function *F) {
    return isInList(ReallocWrappers, F);
}

bool isFreeWrapper(Function *F) {
    return isInList(FreeWrappers, F);
}

bool isAllocationFunc(Function *F) {
    return isMalloc(F,1) || isMalign(F,2) || isCalloc(F,2) || isRealloc(F,2) ||
           isMallocWrapper(F) || isCallocWrapper(F) || isReallocWrapper(F);
}

bool isFreeFunc(Function *F) {
    return isFree(F) || isFreeWrapper(F);
}

static bool isHeapAllocation(CallSite &CS,
                             AllocationSite::AllocationType &CallType,
                             bool &IsWrapped){
    Function *F= CS.getCalledFunction();
    int argNum = CS.getNumArgOperands();

    if (!F || !F->hasName() || F->isIntrinsic())
        return false;

    if (isMalloc(F,argNum)) {
        CallType = AllocationSite::Malloc;
        IsWrapped = false;
    } else if (isCalloc(F,argNum)) {
        CallType = AllocationSite::Calloc;
        IsWrapped = false;
    } else if (isRealloc(F,argNum)) {
        CallType = AllocationSite::Realloc;
        IsWrapped = false;
    } else if (isMalign(F,argNum)) {
        CallType = AllocationSite::Malign;
        IsWrapped = false;
    }else if (isMallocWrapper(F)) {
        CallType = AllocationSite::Malloc;
        IsWrapped = true;
    } else if (isCallocWrapper(F)) {
        CallType = AllocationSite::Calloc;
        IsWrapped = true;
    } else if (isReallocWrapper(F)) {
        CallType = AllocationSite::Realloc;
        IsWrapped = true;
    } else {
        return false;
    }

    return true;
}

int getSizeArg(Function *F) {
    const std::string &name = F->getName().str();

    auto it = MallocFuncs.find(name);
    if (it != MallocFuncs.end())
        return it->second;

    it = MallocWrappers.find(name);
    if (it != MallocWrappers.end())
        return it->second;

    it = MalignFuncs.find(name);
    if(it != MalignFuncs.end())
        return it->second;

    return -1;
}

bool isAllocation(Instruction *I,AllocationSite &AS){
    if(!I)
        return false;

    //we do not need to handle the stack
    if(isa<CallInst>(I)||isa<InvokeInst>(I)){
        CallSite CS(I);
        if(isHeapAllocation(CS,AS.CallType,AS.IsWrapped)){
            AS.Allocation = I;
            if(AS.CallType == AllocationSite::Malloc){
                Function *F = CS.getCalledFunction();
                AS.SizeArg = getSizeArg(F);
            }else if (AS.CallType == AllocationSite::Realloc) {
                AS.SizeArg = 1;
            }else if(AS.CallType == AllocationSite::Malign){
                Function *F = CS.getCalledFunction();
                AS.SizeArg = getSizeArg(F);
            }
            return true;
        }
    }

    return false;
}

const SCEV *AllocationSite::getSizeSCEV(ScalarEvolution &SE) {
    switch (CallType) {
        case Malloc:
        case Realloc:
            return SE.getSCEV(CallSite(Allocation).getArgOperand(SizeArg));
        case Calloc: {
            CallSite CS(Allocation);
            Value *NumElements = CS.getArgOperand(0);
            Value *ElementSize = CS.getArgOperand(1);
            return SE.getMulExpr(SE.getSCEV(NumElements), SE.getSCEV(ElementSize), SCEV::FlagNUW);
        }
        case Alloca: {
            AllocaInst *AI = cast<AllocaInst>(Allocation);
            IntegerType *i64Ty = Type::getInt64Ty(AI->getContext());
            const SCEV *Size = SE.getSizeOfExpr(i64Ty, AI->getAllocatedType());

            if (AI->isArrayAllocation())
                Size = SE.getMulExpr(Size, SE.getSCEV(AI->getArraySize()), SCEV::FlagNUW);

            return Size;
        }
        case Malign: {
            return  SE.getSCEV(CallSite(Allocation).getArgOperand(SizeArg));

        }
    }
    return nullptr;
}

const SCEV *getGlobalSizeSCEV(GlobalVariable *GV, ScalarEvolution &SE) {
    return SE.getSizeOfExpr(Type::getInt64Ty(GV->getContext()),GV->getType()->getPointerElementType());
}
