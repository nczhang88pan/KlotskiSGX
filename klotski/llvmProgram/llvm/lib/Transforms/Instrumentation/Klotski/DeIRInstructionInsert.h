//
// Created by alax on 6/11/18.
//

#ifndef LLVM_DEIRINSTRUCTIONINSERT_H
#define LLVM_DEIRINSTRUCTIONINSERT_H

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
#include <string>
#include <set>
#include <unordered_map>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <queue>
#include <iostream>
#include <fstream>
#include "DataAnalysis.h"
#include "Global.h"

#include "unSafeObject.h"

extern bool supportBigObject;

class DeIRInstructionInsert : public ModulePass{
    friend class UnSafeOBjects;

public:
    static char ID;
    typedef std::unordered_map<Value*,Value*> ShadowMap;
    typedef std::multimap<Value*,Value*> ShadowMultiMap;
    typedef std::vector<Value*> RandPointVector;
    DeIRInstructionInsert():ModulePass(ID){
        this->AA = NULL;
        initializeDeIRInstructionInsertPass(*PassRegistry::getPassRegistry());
    }
    StringRef getPassName() const override;
    void getAnalysisUsage(AnalysisUsage &AU) const override;
    virtual bool runOnModule(Module &M) override ;
    bool runFunction(Function &F);
    virtual bool doInitialization(Module &M) override;
    bool verdictFromName(Function &F);
    BasicBlock *itrSplitBBIntoSmallOnes(BasicBlock *bb,DominatorTree *DT,LoopInfo *LI);

private:
    bool runAnalysisPass(IterativeModulePass *Pass,Module &M);
    int checkAndDerefenceInstr(BasicBlock::iterator &I,DataFlowResult *DFR);


    Value* instrumentArg(BasicBlock &entryBB,Function::arg_iterator &I,DataFlowResult &DL);
    bool constructBBDereferenceSet(DataFlowResult *DFR,BasicBlock *BB,SmallVector<BasicBlock *,4> preBBSet);

    int instrumentAlloc(inst_iterator &I,const DataLayout &DL);

    bool replaceConstantFloatValueInALoopWithLocalValue(Loop *topLevelLoop,Function &F);
    int instrumentPHI(BasicBlock::iterator &I,DataFlowResult *DFR);
    int instrumentNormalAlloc(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentCall(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentStore(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentCmp(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentLoad(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentCast(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentGEP(BasicBlock::iterator &I,BlockResult &BR);
    int instrumentSelect(BasicBlock::iterator &I,BlockResult &BR);

    Value* getDereferenceValueOfAPointer(BasicBlock::iterator &I,Value *value, BlockResult &BR,int &count);
    Value* getDereferenceValueOfAPointer_nonOptimization(BasicBlock::iterator &I,Value *value, BlockResult &BR,int &count);
    Value* getDereferenceValueOfAPointer_controlFlow(BasicBlock::iterator &I,Value *value, BlockResult &BR,int &count);

    Function *addressDereference64;
    Function *reDereference64;
    InlineAsm *inlineAddressDereference;
    InlineAsm *inlineAddressDereference_controlFlow;
    InlineAsm *inlineGetVirtualAddress;

    Function *reserveToSlot[2];
    InlineAsm *inlineReserveToSlot[2];

    Type *Int64PtrTy;
    Type *Int64Ty;
    Type *Int32PtrTy;
    Type *Int32Ty;
    Type *Int8Ty;
    Type *Int8PtrTy;

    UnSafeOBjects unSafeOBjects;

    Value *ShadowZero;

    std::vector<Value *> stackValues;

    std::queue<Value *> sourcePointersSet;

    ShadowMap constantFPPool;
    RandPointVector randomPointSet;
    RandPointVector noneRandomPointSet;

    ShadowMultiMap unsolvedPHIanditsValue;
    //the mapping of pointers and their shadowpointers
    ShadowMap shadowMap;
    ShadowMap localVarPointerUseTrack;
    ShadowMap stackPointerUseTrack;
    //the main difference between shadowMap and allocatePointers is that, an allocatePointer's
    //shadow value is a space in the stack, dereferencing these values is loading them from the
    //shadow stack space instead of replacing them with their shadow values.
    ShadowMap allocatePointers; //allocate a space for a point [pointer,shadowpointer]
    void reset(){
        unsolvedPHIanditsValue.clear();
        allocatePointers.clear();
        while(sourcePointersSet.empty()){
            sourcePointersSet.pop();
        }
        shadowMap.clear();
        stackValues.clear();
        constantFPPool.clear();
        currentFunction = NULL;
        AA = NULL;
    }

    AliasAnalysis *AA;
    Function* currentFunction;
};

#endif //LLVM_DEIRINSTRUCTIONINSERT_H
