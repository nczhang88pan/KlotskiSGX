//
// Created by alax on 6/8/18.
//

#ifndef LLVM_ALLOCATION_H
#define LLVM_ALLOCATION_H

#include <llvm/Pass.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/Analysis/ScalarEvolution.h>
#include <llvm/IR/DataLayout.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/CallSite.h>
#include <llvm/Analysis/LoopInfo.h>
#include <set>

using namespace llvm;
#define ifcast(ty, var, val) if (ty *var = dyn_cast<ty>(val))
#define ifncast(ty, var, val) ty *var = dyn_cast<ty>(val); if (var == nullptr)

struct AllocationSite{
    enum AllocationType {Malloc,Calloc,Realloc,Alloca,Malign};
    static const size_t  NoSize = (size_t)(-1LL);

    Instruction *Allocation;
    AllocationType CallType;
    int SizeArg;
    bool IsWrapped;

    inline bool isStackAllocation() {return CallType == Alloca;}
    inline bool isHeapAllocation() {return CallType != Alloca;}

    const SCEV *getSizeSCEV(ScalarEvolution &SE);

};

bool isMalloc(Function *F);
bool isCalloc(Function *F);
bool isRealloc(Function *F);
bool isFree(Function *F);
bool isMallocWrapper(Function *F);
bool isCallocWrapper(Function *F);
bool isReallocWrapper(Function *F);
bool isFreeWrapper(Function *F);
bool isAllocationFunc(Function *F);
bool isFreeFunc(Function *F);
bool functionShouldBeIgnored(Function *F);

int getSizeArg(Function *F);

bool isAllocation(Instruction *I, AllocationSite &AI);

const SCEV *getGlobalSizeSCEV(GlobalVariable *GV, ScalarEvolution &SE);

//get the first operand
inline Value* otherOperand(Instruction *I, Value *Op) {
    assert(I->getNumOperands() == 2);

    if (I->getOperand(0) == Op)
        return I->getOperand(1);

    assert(I->getOperand(1) == Op);
    return I->getOperand(0);
}



#endif //LLVM_ALLOCATION_H
