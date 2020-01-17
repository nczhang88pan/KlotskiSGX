//
// Created by alax on 7/19/18.
//

#ifndef LLVM_GLOBAL_H_H
#define LLVM_GLOBAL_H_H

#include <llvm/IR/DebugInfo.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Instructions.h>
#include <llvm/ADT/DenseMap.h>
#include <llvm/ADT/SmallPtrSet.h>
#include <llvm/ADT/StringExtras.h>
#include <llvm/Support/Path.h>
#include <llvm/Support/raw_ostream.h>
#include "llvm/Support/CommandLine.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include <map>
#include <unordered_map>
#include <set>
#include <unordered_set>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include "StructAnalyzer.h"


typedef std::vector< std::pair<llvm::Module*, llvm::StringRef> > ModuleList;
typedef std::unordered_map<llvm::Module*, llvm::StringRef> ModuleMap;
typedef std::unordered_map<std::string, llvm::Function*> FuncMap;
typedef std::unordered_map<std::string, llvm::GlobalVariable*> GObjMap;
typedef llvm::SmallPtrSet<llvm::CallInst*, 8> CallInstSet;
typedef llvm::SmallPtrSet<llvm::Function*, 8> FuncSet;
typedef std::unordered_map<std::string, FuncSet> FuncPtrMap;

typedef llvm::DenseMap<llvm::Function*, CallInstSet> CallerMap;
typedef llvm::DenseMap<llvm::CallInst*, FuncSet> CalleeMap;

typedef std::unordered_map<std::string, int> SimpleTaintMap;

using namespace llvm;

#define KA_LOG(lv, stmt)							\
	do {											\
		if (VerboseLevel >= lv)						\
			llvm::errs() << stmt;					\
	} while(0)

#define RES_REPORT(stmt) KA_LOG(1, "[REP] " << stmt<< "\n");

#define WARNING(stmt) KA_LOG(2, "[WARN] " << stmt<< "\n");

#define STA_DEBUG(stmt) KA_LOG(3, "[DEBUG] " << stmt << "\n");


//for unSafeObject trace
typedef std::unordered_map<std::string, int> GContext;
typedef std::unordered_map<llvm::Function*,unsigned > CallStack;
typedef std::unordered_set<llvm::Instruction*> InstTaintedStateSet;
struct TracedFunction{
    Function *func;
    unsigned argTaintedState;    //if the nth arg is tainted, thus (taintedArg & (1<<n))==1
    unsigned propagateOut; //propagate out;
    bool retTainted;
    std::unordered_set<std::string> argTaintStateAnnotationSet;        //record the tainted
    InstTaintedStateSet instTaintedStateSet;        //tainted instruction
};
typedef std::unordered_map<llvm::Function*,SmallVector<struct TracedFunction *,4>> TContext;


class GlobalContext {
private:
    // pass specific data
    std::map<std::string, void*> PassData;

public:
    bool add(std::string name, void* data) {
        if (PassData.find(name) != PassData.end())
            return false;

        PassData[name] = data;
        return true;
    }

    void* get(std::string name) {
        std::map<std::string, void*>::iterator itr;

        itr = PassData.find(name);
        if (itr != PassData.end())
            return itr->second;
        else
            return nullptr;
    }

    // StructAnalyzer
    StructAnalyzer structAnalyzer;

    // Map global object name to object definition
    GObjMap Gobjs;

    // Map global function name to function defination
    FuncMap Funcs;

    // Map function pointers (IDs) to possible assignments
    FuncPtrMap FuncPtrs;

    // functions whose addresses are taken
    FuncSet AddressTakenFuncs;

    // Map a callsite to all potential callee functions.
    CalleeMap Callees;

    // Map a function to all potential caller instructions.
    CallerMap Callers;

    // Indirect call instructions
    std::vector<CallInst *> IndirectCallInsts;

    ModuleList Modules;

    ModuleMap ModuleMaps;
    std::set<std::string> InvolvedModules;

    SimpleTaintMap STaints;
};

class IterativeModulePass {
protected:
    GlobalContext *Ctx;
    const char *ID;
public:
    IterativeModulePass(GlobalContext *Ctx_, const char *ID_)
            : Ctx(Ctx_), ID(ID_) { }

    // run on each module before iterative pass
    virtual bool doModuleInitialization(llvm::Module *M)
    { return true; }

    // run on each module after iterative pass
    virtual bool doModuleFinalization(llvm::Module *M)
    { return true; }

    virtual bool doFunctionInit(llvm::Function *F)
    { return true; }

    virtual bool runOnFunction(llvm::Function *F)
    {return true;}

    virtual bool doFunctionFinal(llvm::Function *F)
    { return true; }
};

#endif //LLVM_GLOBAL_H_H
