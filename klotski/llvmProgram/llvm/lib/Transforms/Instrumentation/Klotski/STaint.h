//
// Created by alax on 7/12/18.
//

#ifndef LLVM_STAINT_H
#define LLVM_STAINT_H
#include <unordered_set>
#include <unordered_map>
#include <set>

#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/CallSite.h"
#include "llvm/Analysis/LoopInfo.h"
#include "Global.h"


class STaint :public IterativeModulePass{
private:
    llvm::Module *CurrentModule;
//    TaintSignature *Sig;

    std::unordered_set<std::string> SStructs;
    std::unordered_set<std::string> SArgs;
    typedef std::unordered_map<llvm::Instruction*, int> LContext;
    LContext CurrentLContext;  //Local Context

    SimpleTaintMap CurrentGContext; //Global Context

    typedef std::unordered_set<llvm::Function*> CallStack;
    CallStack CurrentCallStack;

    bool annotateTaint(llvm::Function*);
    bool annotateSink(llvm::Function*);


    bool isSafeGEP(llvm::GetElementPtrInst*);

    int getTaint(llvm::Value*,ScalarEvolution &SE);
    bool setTaint(llvm::Value*,ScalarEvolution &SE, int = 0);
    bool taintSpecial(llvm::StringRef, llvm::CallInst*, bool&);
    bool taintStruct(llvm::Type*);
    bool taintArgs(llvm::Function*);
    bool taintCaller(llvm::Function*,ScalarEvolution &SE);
    bool taintCallee(llvm::Function*, llvm::Function*);
    bool handleAsm(llvm::CallInst*);
    bool forwardTaint(llvm::Function*,llvm::ScalarEvolution &SE);
    bool backwardTaint(llvm::Function*,llvm::ScalarEvolution &SE);
    bool runFunction(llvm::Function*,ScalarEvolution &SE, bool);
    bool runOnFunction(llvm::Function *F,ScalarEvolution *SE);

    bool checkSinks(llvm::Module*);
    void collectWrites(llvm::Module*);


public:
    STaint(llvm::Module *M,GlobalContext *Ctx_):
            IterativeModulePass(Ctx_, "Taint"),
            CurrentModule(M){}
    ~STaint();

    bool doModuleInitialization(llvm::Module*);
    bool doModuleFinalization(llvm::Module *M);

    void contextReset(Function*);

    void dumpWrites();

    // debug
    void dumpTaints();

};



#endif //LLVM_STAINT_H
