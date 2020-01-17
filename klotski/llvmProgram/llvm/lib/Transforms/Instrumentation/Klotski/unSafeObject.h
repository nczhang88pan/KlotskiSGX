//
// Created by alax on 6/6/18.
//

#ifndef LLVM_SAFEOBJECT_H
#define LLVM_SAFEOBJECT_H
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Triple.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include "llvm/Support/Process.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Transforms/Scalar.h"

#include <sys/types.h>
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/ScalarEvolutionAliasAnalysis.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"

#include <llvm/Pass.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include <llvm/Analysis/TargetLibraryInfo.h>
#include <llvm/Analysis/ScalarEvolution.h>
#include <llvm/Analysis/ScalarEvolutionExpander.h>
#include <llvm/Transforms/Utils/LoopUtils.h>
#include <llvm/ADT/SmallSet.h>
#include <llvm/ADT/DenseSet.h>
#include <llvm/ADT/DenseMap.h>
#include "DataAnalysis.h"
#include "Global.h"

#include <unistd.h>
#include <stdio.h>
#include <queue>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <set>
#include <unordered_map>
#include <unordered_set>

using namespace llvm;

#define BLOCKSIZE 0x800

#define CONTEXT_SENSITIVE 1
#define INSTRUMENTATION_STATS 1

#define DO_FORWARD 1
//#define DO_BACKWARD 1

#define CLEAN_TAG	0
#define SAFE_TAG	1
#define UNSAFE_TAG	2

class UnSafeOBjects{
public:
    friend class DeIRInstructionInsert;



    UnSafeOBjects(){}
    ~UnSafeOBjects(){
        for(auto itrSet:CurrentTContext){
            while (!itrSet.second.empty()){
                struct TracedFunction * tf = itrSet.second.pop_back_val();
                tf->func = NULL;
                tf->argTaintStateAnnotationSet.clear();
                tf->instTaintedStateSet.clear();
                free(tf);
            }
        }
    }

protected:
    Module *CurrentModule;
    const DataLayout *DL;
    DominatorTree *DT;
    LoopInfo *LI;
    ScalarEvolution *SE;
    GlobalContext *Ctx;

    DenseSet<Value*>  functionNeedUpdate;
    DenseMap<Function *,DenseSet<int> *> unSafeArgment;
    DenseMap<Function *,DenseSet<Value*> *> unSafeAllocations;
    DenseMap<Function *,DenseSet<Instruction*> *> unSafePropagation;
    DenseMap<Value*,DenseSet<Instruction*> *>  unKnownGlobalPointerUserMap; //only load and store


    const SCEV *BlockBoundary; //we set BlockBoundary to 2k
    const SCEV *trickyOne; // this is a tricky one for testing the allocate


    void findUnSafeGlobals(Module &M);
    void findUnSafeGEPs(Function &F,
                        DenseMap<Value*,std::pair<const SCEV*,const SCEV*>> &PointerBounds);
    void findUnSafeAllocation(Function &F);

    void findUnSafeGEP(Function &F);
    void propagateAllocationOffet(Function &F,DenseMap<Value*,std::pair<const SCEV*,const SCEV*>> &PointerBounds);

    const SCEV *getGEPOffsetSCEV(GetElementPtrInst *getElementPtrInst,bool NoWrap=false);

    const SCEV *getPointerCastOrArithOffset(Instruction *UI,Value *I);

    const SCEV *addSCEVs(const SCEV *LHS, const SCEV *RHS);

    bool isNotDereferencedInLastLoopIteration(
            GetElementPtrInst *GEP, InductionDescriptor &D);

    bool isNotDerefecencedBeyondBoundary(Value *Ptr, const SCEV *Offset, const SCEV *Boundary);

    //
    bool findAllDereferencedBytes(Value *ptr,SmallVectorImpl<const SCEV*> &DerefBytes);

    const SCEV *getSizeOfSCEV(Type *Ty);

    bool compareSCEVs(ICmpInst::Predicate Pred, const SCEV *LHS, const SCEV *RHS);

    bool needsPropagation(Function *function, Instruction *GEP);
    void setPropagation(Function *function,Instruction *GEP);

    void setUnsafe(Function *function,Value *Allocation);

    void propagateUnSafeTags(Function &F);
    void propagateUnSafeTags(Function &F,SmallVector<std::pair<Instruction*, Value*>, 32> &Worklist,
                             DenseSet<std::pair<Instruction*, Value*>> &VisitedPHINodes);

    bool instrumentCall(Function *func, Instruction* instruction, Value* ptr);
    bool instrumentRet(Function *func, Instruction* instruction);

    void insertToSet(DenseSet<Value*> &set,Value *frunction);
    bool isIgnoredGlobal(Value*);
    bool isUncertainGlobal(GlobalVariable *);
    bool checkGlobalPointerStore(Function &function1,Instruction *store);


    //context sensitive
    CallStack CurrentCallStack;
    SmallVector<Function *,32> TracingFunctionWorkSet;

    GContext CurrentGContext; //global context                              [stringId, tag]
    GContext SpecialAddressId;//A spical add Id may contain unsafe pointer  [stringId, tag] module.functionName.arg.Called
    TContext CurrentTContext; //tracing context, typically it contains the state of argments, tainted instructions and ret

    std::unordered_map<llvm::Function *,std::unordered_map<Instruction*, std::string>> UnSafeMallocInst; //unSafe MallocInst

    bool initGM(Module *F,GlobalContext *);
    void reset(Function *F);
    int setTaint(Value *value, struct TracedFunction * currentTF);
    int getTaint(Value *value,struct TracedFunction * currentTF);

    bool isUnSafeSource(Function *F,Value *value);
    bool propagateInFunction(Function *F,bool checkerCaller);
    bool forwardTaint(Function &F,struct TracedFunction * currentTF);
    void taintCaller(Function &F);
    bool handleAsm(CallInst *CI,struct TracedFunction * currentTF);
    struct TracedFunction *getTFResult(Function *calledF, unsigned argTaintState);

    //we handle specify malloc call that have known or unknown size.
    bool handleSpecifyCallInst(CallInst *instruction,int &taint,struct TracedFunction * currentTF);
    bool isIgnoredFunction(Function *func);
    bool runOnFunction(Function &F,struct TracedFunction * currentTF);
    bool runOnModule(Module &M);

};

inline bool shouldInstrument(Function *F){
    if (F->isDeclaration())
        return false;

    if (F->isIntrinsic())
        return false;

    if(F && F->hasName()){
//        StringRef name = F->getName();
//        if(name.startswith("")){
//
//        }
    }
    return true;
}

#endif //LLVM_SAFEOBJECT_H
