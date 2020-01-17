//===- InferFunctionAttrs.cpp - Infer implicit function attributes --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/IPO/InferFunctionAttrs.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/MemoryBuiltins.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BuildLibCalls.h"
#include "llvm/IR/InlineAsm.h"
using namespace llvm;

#define DEBUG_TYPE "inferattrs"

static bool inferAllPrototypeAttributes(Module &M,
                                        const TargetLibraryInfo &TLI) {
  bool Changed = false;

  for (Function &F : M.functions())
    // We only infer things using the prototype and the name; we don't need
    // definitions.
    if (F.isDeclaration() && !F.hasFnAttribute((Attribute::OptimizeNone)))
      Changed |= inferLibFuncAttributes(F, TLI);

  return Changed;
}

PreservedAnalyses InferFunctionAttrsPass::run(Module &M,
                                              ModuleAnalysisManager &AM) {
  auto &TLI = AM.getResult<TargetLibraryAnalysis>(M);

  if (!inferAllPrototypeAttributes(M, TLI))
    // If we didn't infer anything, preserve all analyses.
    return PreservedAnalyses::all();

  // Otherwise, we may have changed fundamental function attributes, so clear
  // out all the passes.
  return PreservedAnalyses::none();
}

namespace {
struct InferFunctionAttrsLegacyPass : public ModulePass {
  static char ID; // Pass identification, replacement for typeid
  InferFunctionAttrsLegacyPass() : ModulePass(ID) {
    initializeInferFunctionAttrsLegacyPassPass(
        *PassRegistry::getPassRegistry());
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<TargetLibraryInfoWrapperPass>();
  }

  bool runOnModule(Module &M) override {
    if (skipModule(M))
      return false;
       for (Function &F : M.functions()){
          int i=0;
           std::vector<Instruction*> worklist;
          for(auto &B: F){
              for(auto &I:B){
                  CallInst *callInst = dyn_cast_or_null<CallInst>(&I);
                  if(callInst ){
                      Function *callee= callInst->getCalledFunction();
                      if(callee && callee->getName().startswith("addressDereference64")){

                          if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                              worklist.push_back(callInst);
//                              callInst->print(errs());errs()<<"find function\n";
                          }
                      }
                      if(callInst->isInlineAsm()){
                            InlineAsm *inlineAsm = dyn_cast_or_null<InlineAsm>(callInst->getCalledValue());
                            if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("rorx $$0xb,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x35,%r14,$0")){
                                  if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                                       worklist.push_back(callInst);
                                  }else if(callInst->getNumUses()==0){
//                                      errs()<<"============\n";
//                                      callInst->print(errs());errs()<<"\n";
                                      for (User *User : callInst->users()){
                                          User->print(errs());errs()<<"\n";
                                      }
                                      worklist.push_back(callInst);

                                  }

                            }
                          if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("rorx $$0xb,$1,%r14;callq *0x60(%r15);rorx $$0x35,%r14,$0")){
                              if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                                  worklist.push_back(callInst);
                              } else if(callInst->getNumUses()==0){
//                                  errs()<<"============\n";
//                                    callInst->print(errs());errs()<<"\n";
                                  for (User *User : callInst->users()){
                                      User->print(errs());errs()<<"\n";
                                  }
                                  worklist.push_back(callInst);

                              }
                          }
                          if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("movq $1,%r14;callq *0x60(%r15);movq %r14,$0")){
                              if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                                  worklist.push_back(callInst);
                              } else if(callInst->getNumUses()==0){
//                                  errs()<<"============\n";
//                                    callInst->print(errs());errs()<<"\n";
                                  for (User *User : callInst->users()){
                                      User->print(errs());errs()<<"\n";
                                  }
                                  worklist.push_back(callInst);

                              }
                          }
                          if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("movq $1,%r14;callq *0x60(%r15);rorx $$0x35,%r14,$0")){
                              if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                                  worklist.push_back(callInst);
                              } else if(callInst->getNumUses()==0){
//                                  errs()<<"============\n";
//                                    callInst->print(errs());errs()<<"\n";
                                  for (User *User : callInst->users()){
                                      User->print(errs());errs()<<"\n";
                                  }
                                  worklist.push_back(callInst);

                              }
                          }

                      }
                  }
              }
              i+=B.size();
              
          }
          for(auto itr:worklist){
              itr->eraseFromParent();
          }
           //if a function has less than 10 instructions, we choose to Inline them
          if(i>0 && i<10){
              if(F.hasFnAttribute(Attribute::NoInline)){
                  F.removeFnAttr(Attribute::NoInline);
              }
              F.addFnAttr(Attribute::AlwaysInline);
          }
       }

    auto &TLI = getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
    return inferAllPrototypeAttributes(M, TLI);
  }
};
}

char InferFunctionAttrsLegacyPass::ID = 0;
INITIALIZE_PASS_BEGIN(InferFunctionAttrsLegacyPass, "inferattrs",
                      "Infer set function attributes", false, false)
INITIALIZE_PASS_DEPENDENCY(TargetLibraryInfoWrapperPass)
INITIALIZE_PASS_END(InferFunctionAttrsLegacyPass, "inferattrs",
                    "Infer set function attributes", false, false)

Pass *llvm::createInferFunctionAttrsLegacyPass() {
  return new InferFunctionAttrsLegacyPass();
}
