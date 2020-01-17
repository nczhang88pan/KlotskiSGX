//
// Created by alax on 8/8/17.
//

#include "EliminateConstantInAFunctionBody.h"
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallSet.h"
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
#include "llvm/IR/Module.h"
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
#include <set>
#include <unordered_map>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <queue>
#include <iostream>
#include <fstream>
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/ScalarEvolutionAliasAnalysis.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"

using namespace llvm;

namespace {
    class EliminateConstantInAFunctionBody : public FunctionPass {
    public:
        static char ID;
        EliminateConstantInAFunctionBody():FunctionPass(ID){
            initializeEliminateConstantInAFunctionBodyPass(*PassRegistry::getPassRegistry());
        }
        //void getAnalysisUsage(AnalysisUsage &AU) const override;
        virtual bool runOnFunction(Function &F) override ;
        StringRef getPassName() const override;
    };

}

char EliminateConstantInAFunctionBody::ID = 0;
INITIALIZE_PASS_BEGIN(EliminateConstantInAFunctionBody, "EliminateConstantInAFunctionBody-module",
                      "ECIAFB : Store a constant value into a stack slot.", false, true)
//    INITIALIZE_PASS_DEPENDENCY(AssumptionCacheTracker)
INITIALIZE_PASS_END(EliminateConstantInAFunctionBody, "EliminateConstantInAFunctionBody-module",
                    "ECIAFB : Store a constant value into a stack slot.", false, true)


StringRef EliminateConstantInAFunctionBody::getPassName() const {
    return "EliminateConstantInAFunctionBody";
}

FunctionPass *llvm::createEliminateConstantInAFunctionBodyFunctionPass(bool CompileKernel, bool Recover, bool UseAfterScope) {
    return new EliminateConstantInAFunctionBody();
}

bool EliminateConstantInAFunctionBody::runOnFunction(Function &F) {
    std::vector<Value*> constantList;
    std::map<Value*,Value*> constantValueMap;
    bool isChanged =false;
    for(Function::iterator BB=F.begin(),BE=F.end();BB!=BE;++BB){
        for(BasicBlock::iterator I=BB->begin(),E=BB->end();I!=E;++I){
//            if(isa<CallInst>(I)){
//                continue;
//            }
            if(isa<StoreInst>(I)){
                continue;
            }
            for(unsigned index=0;index<I->getNumOperands();index++){
                Value * value = I->getOperand(index);
                // if(F.getName().equals("fabs")){
                //     if(isa<Constant>(value)){
                //         //value->print(errs());errs()<<"a constant \n";
                //         //I->print(errs());errs()<<"org inst\n";
                //         if(constantValueMap[value]){
                //             I->setOperand(index,constantValueMap[value]);
                //             isChanged = true;
                //         } else{
                //             IRBuilder<> IRB(&*F.begin()->begin());
                //             AllocaInst *ai=IRB.CreateAlloca(value->getType());
                //             IRB.CreateStore(value,ai)->setVolatile(true);
                //             LoadInst *li = IRB.CreateLoad(ai);
                //             li->setVolatile(true);
                //             constantValueMap[value]=li;
                //             I->setOperand(index,li);
                //             isChanged = true;
                //         }
                //     }
                // }
                if(isa<ConstantFP>(value)){
                    //value->print(errs());errs()<<"a constant \n";
                    //I->print(errs());errs()<<"org inst\n";
                    if(constantValueMap[value]){
                        I->setOperand(index,constantValueMap[value]);
                        isChanged = true;
                    } else{
                        IRBuilder<> IRB(&*F.begin()->begin());
                        AllocaInst *ai=IRB.CreateAlloca(value->getType());
                        IRB.CreateStore(value,ai);
                        LoadInst *li = IRB.CreateLoad(ai);
                        li->setVolatile(true);
                        constantValueMap[value]=li;
                        I->setOperand(index,li);
                        isChanged = true;
                    }
//                    value->print(errs());errs()<<"a constant in a loop\n";
//                    for(auto *use:value->users()){
//                        errs()<<" :";use->print(errs());errs()<<" ";
//                        if(Instruction *instructionU = dyn_cast<Instruction>(use)){
//                            errs()<<instructionU->getParent()->getParent()->getName()<<"\n";
//                        }
//                    }
                }
            }
        }
    }

    return isChanged;
}