//
// Created by alax on 6/19/18.
//

#include <llvm/IR/Constants.h>
#include <llvm/Support/raw_ostream.h>
#include "EliminateRedundantDeIR.h"
#include <vector>
using namespace llvm;
bool EliminateRedundantDeIR::runOnModule(Module &M) {
    bool isModified = false;

    //we delete some redundant dereference instruction.

    for(Function &F: M.functions()){
        std::vector<Instruction*> worklist;
        for(auto &B: F){
            for(auto &I:B){
                CallInst *callInst = dyn_cast_or_null<CallInst>(&I);
                if(!callInst)
                    continue;
                if(callInst->isInlineAsm()){
                    InlineAsm *inlineAsm = dyn_cast_or_null<InlineAsm>(callInst->getCalledValue());
                    if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("rorx $$0xb,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x35,%r14,$0")){
                        if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                            worklist.push_back(callInst);
                        }else if(callInst->getNumUses()==0){
                            worklist.push_back(callInst);
                        }

                    }
                    if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("rorx $$0xb,$1,%r14;callq *0x60(%r15);rorx $$0x35,%r14,$0")){
                        if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                            worklist.push_back(callInst);
                        } else if(callInst->getNumUses()==0){
                            worklist.push_back(callInst);
                        }
                    }
                    if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("movq $1,%r14;callq *0x60(%r15);movq %r14,$0")){
                        if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                            worklist.push_back(callInst);
                        } else if(callInst->getNumUses()==0){
                            worklist.push_back(callInst);
                        }
                    }
                    if(inlineAsm && StringRef(inlineAsm->getAsmString()).startswith("movq $1,%r14;callq *0x60(%r15);rorx $$0x35,%r14,$0")){
                        if(dyn_cast_or_null<UndefValue>(callInst->getOperand(0))){
                            worklist.push_back(callInst);
                        } else if(callInst->getNumUses()==0){
                            worklist.push_back(callInst);
                        }
                    }

                }

            }
        }
        if(!worklist.empty()){
            isModified=true;
        }
        for(auto itr:worklist){
            itr->eraseFromParent();
        }
    }

    for(Function &F: M.functions()){
        std::vector<Instruction*> worklist;
        for(Function::iterator BB=F.begin(),BE=F.end();BB!=BE;BB++) {
            //eliminate PHIs that only has one incomming value
            for(BasicBlock::iterator bbB=BB->begin(),bbE=BB->end();bbB!=bbE;bbB++){

//                bbB->print(errs());errs()<<"fuck1 \n";

                PHINode *phiNode=dyn_cast_or_null<PHINode>(&*bbB);

                if(phiNode){
//                phiNode->print(errs());errs()<<"\n";
                    std::map<Value *,SmallVector<BasicBlock *,4>> valueMap;
                    for(int i=0,e=phiNode->getNumIncomingValues();i!=e;i++){
                        Value *incomingValue = phiNode->getIncomingValue(i);
                        valueMap[incomingValue].push_back(phiNode->getIncomingBlock(i));
                    }

                    if(valueMap.size()==1){
                        Value* shadowPointer = valueMap.begin()->first;
                        phiNode->replaceAllUsesWith(shadowPointer);
                        worklist.push_back(phiNode);
                    }

                }
            }
        }
        if(!worklist.empty()){
            isModified=true;
        }
        for(auto itr:worklist){
            itr->eraseFromParent();
        }
    }
    for(Function &F: M.functions()){
        if(F.hasName() && F.getName().startswith("jinit_inverse_dct")){
            F.print(errs());
        }
    }
    return  isModified;

}

INITIALIZE_PASS_BEGIN(EliminateRedundantDeIR, "EliminateRedundantDeIR-module",
                      "EliminateRedundantDeIR.", false, true)
INITIALIZE_PASS_END(EliminateRedundantDeIR, "EliminateRedundantDeIR-module",
                    "EliminateRedundantDeIR.", false, true)

char EliminateRedundantDeIR::ID = 0;
ModulePass *llvm::createEliminateRedundantDeIRModulePass(bool CompileKernel, bool Recover, bool UseAfterScope) {
    return new EliminateRedundantDeIR();
}

