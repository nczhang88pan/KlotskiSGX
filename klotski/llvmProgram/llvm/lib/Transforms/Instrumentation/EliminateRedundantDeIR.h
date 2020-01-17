//
// Created by alax on 6/19/18.
//

#ifndef LLVM_CREATEELIMINATEREDUNDANTDEIR_H
#define LLVM_CREATEELIMINATEREDUNDANTDEIR_H
#include "llvm/Transforms/Utils/ModuleUtils.h"
#include <llvm/Pass.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/IR/InlineAsm.h"

using namespace llvm;
class EliminateRedundantDeIR :public ModulePass{
public:
    static char ID;
    EliminateRedundantDeIR():ModulePass(ID){
        initializeEliminateRedundantDeIRPass(*PassRegistry::getPassRegistry());
    }
    virtual bool runOnModule(Module &M) override ;
};



#endif //LLVM_CREATEELIMINATEREDUNDANTDEIR_H
