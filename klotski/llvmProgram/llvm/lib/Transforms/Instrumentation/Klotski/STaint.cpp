//
// Created by alax on 7/12/18.
//
#define DEBUG_TYPE "staint"
#include "llvm/Pass.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Format.h"

#include "STaint.h"
#include "Annotation.h"
using namespace llvm;

//debug
static unsigned VerboseLevel=2;
#define  TM (Ctx->STaints)

#define CONTEXT_SENSITIVE 1
#define INSTRUMENTATION_STATS 1

#define DO_FORWARD 1
//#define DO_BACKWARD 1

#define CLEAN_TAG	0
#define SAFE_TAG	1
#define UNSAFE_TAG	2

STATISTIC(NumFunctions, "Total number of functions");
STATISTIC(NumWrites, "Total number of writes");
STATISTIC(NumUnsafeWrites, "Number of unsafe writes");
STATISTIC(NumSafeWrites, "Number of safe writes");
STATISTIC(NumGEP, "Total number of pointer arithmetic");
STATISTIC(NumUnsafeGEP, "Number of unsafe pointer arithmetic");
STATISTIC(NumSafeGEP, "Number of safe pointer arithmetic");
STATISTIC(NumUnsafeNCGEP, "Number of unsafe and non-critical pointer arithmetic");

static inline bool setTag(SimpleTaintMap &map, std::string &Id, int tag){
    auto itr = map.find(Id);
    map.find(Id);
    if(itr == map.end() || itr->second < tag){
        map[Id]=tag;
        return true;
    }
    return false;
}

bool STaint::setTaint(llvm::Value *V,ScalarEvolution &SE, int tag) {
    bool ret = false;
    if(Instruction *I = dyn_cast<Instruction>(V)){
        //if already tainted,update the tag if possible
        auto itr = CurrentLContext.find(I);
        if(itr == CurrentLContext.end() || itr->second < tag){
            CurrentLContext[I] = tag;
            ret = true;
        }

        MDNode *MD = I->getMetadata(MD_Taint);
        std::string stag = tag==1 ? "safe":"unsafe";
        //if the instruction is tainted and its tag is marked as safe, return
        if(MD!= nullptr && getStringFromMD(MD).compare(stag) && tag==1){
            return ret;
        }

        //taint the instruction
        LLVMContext &VMCtx = I->getContext();
        MD = MDNode::get(VMCtx,MDString::get(VMCtx,stag));
        I->setMetadata(MD_Taint,MD);

        //return if this instruction is non AllocaInst
        if(!isa<AllocaInst>(I))
            return ret;
    }

    //get value's annotation, typically, values here are sources.
    std::string Id=getAnnotation(V,CurrentModule);
    if(!Id.empty()){
        if(setTag(CurrentGContext,Id,tag))
            ret = true;

        if(setTag(TM,Id,tag)){
            STA_DEBUG("setTaint ID = " << Id << ", V = " << *V << "\n");
        }
    }
    return ret;
}

int STaint::getTaint(llvm::Value *V,ScalarEvolution &SE) {

    if(Instruction *I=dyn_cast<Instruction>(V)){
        auto itr = CurrentLContext.find(I);
        if(itr!=CurrentLContext.end()){
            return itr->second;
        }
        //thus we do not find the value in CurrentLContext
        //if this instruction is a allocaFun, it may be unsafe.
//        if(!isa<AllocaInst>(I))
        if(!isa<CallInst>(I))
            return CLEAN_TAG;
    }

    std::string Id = getAnnotation(V,CurrentModule);
    if(!Id.empty()){
        //check the state of this value from the CurrentGContext
        auto itr = CurrentGContext.find(Id);
        if(itr != CurrentGContext.end()){
            return itr->second;
        }
    }

    return CLEAN_TAG;
}

bool STaint::isSafeGEP(llvm::GetElementPtrInst *GEP) {
    //Todo: check the safe state of the GEP
    return false;
}

bool STaint::doModuleInitialization(llvm::Module *) {
    //find all taint source, typically it contains global variables and malloc that larger than a block
    return false;
}

// forward taint propagation
bool STaint::forwardTaint(llvm::Function *F,ScalarEvolution &SE) {
    bool changed = false;
    int taint;
    std::string Id;
    CallInst *CI = nullptr;
    FuncSet *FS;
    Value *SV;

    for(inst_iterator i =inst_begin(F),e = inst_end(F);i!=e;++i){
        Instruction *I = &*i;

        bool MD = CurrentLContext.count(I) ? true : false;

        // if an instruction is already tainted, ignore unless is a call
        if(MD && !isa<CallInst>(I))
            continue;

        //reset the taint state.
        taint = 0;
        switch (I->getOpcode()){
            case Instruction::Load:
                Id = getLoadId(cast<LoadInst>(I));
                if(Id.empty()){
                    WARNING("Empty ID for load " << *I << "\n");
                    break;
                }
                if(CurrentGContext.count(Id)){//if the pointer is record.
                    taint = CurrentGContext[Id];

                    //the loadInst is not taint yet.
                    if(!MD)STA_DEBUG("taint load, id = " << Id << "\n");
                }
                break;
            case Instruction::Store:
                SV = I->getOperand(0);
                taint = getTaint(SV,SE);
                if(taint){
                    //the value is tainted, set the MD_ID metadata of this store as this SV's annotation
                    Id = getStoreId(cast<StoreInst>(I));
                    if(Id.empty()){
                        WARNING("Empty ID for store " << *I << "\n");
                        break;
                    }

                    //taint the pointer
                    setTag(CurrentGContext,Id,taint);
                    if(setTag(TM,Id,taint)){
                        STA_DEBUG("taint store, id = " << Id << "\n");
                    }
                }

                //if the pointer is tainted, taint this Store Instrucion
                SV = I->getOperand(1);
                taint = getTaint(SV,SE);
                break;
            case Instruction::Call:
                //TODO:klotski
                CI = cast<CallInst>(I);
                if(CI->isInlineAsm()) break;

                FS = &Ctx->Callees[CI];
                for(Function *CF : *FS){

                }
                break;
            case Instruction::Ret:
                if(I->getNumOperands()!=0){
                    taint = getTaint(I->getOperand(0),SE);
                    if(taint){
                        STA_DEBUG("taint ret, F = " << F->getName() << "\n");
                        Id = getRetId(F);
                        setTag(CurrentGContext,Id,taint);
                        setTag(TM,Id,taint);
                    }
                }
                break;
            case Instruction::Select:
                taint = getTaint(I->getOperand(1),SE) > taint ? getTaint(I->getOperand(1),SE) : taint;
                taint = getTaint(I->getOperand(2),SE) > taint ? getTaint(I->getOperand(2),SE) : taint;
                break;
            case Instruction::GetElementPtr:
                Id = getAnnotation(I,CurrentModule);
                if(Id.empty()){
                    WARNING("Empty ID for GEP"<<*I<<"\n");
                    taint = getTaint(I->getOperand(0),SE);
                    break;
                }
                if(CurrentGContext.count(Id)){
                    taint = CurrentGContext[Id];
                    break;
                }
                //check/set for sensitive source
                if(SStructs.count(Id) || MD){
                    STA_DEBUG("taint sensitive GEP"<<*I<<", Id = " << Id << "\n");
                    taint = SAFE_TAG;
                    setTag(CurrentGContext,Id,taint);
                    setTag(TM,Id,taint);
                }

                if(taint && !isSafeGEP(cast<GetElementPtrInst>(I)))
                    taint=UNSAFE_TAG;
                break;
            case Instruction::ICmp:
            case Instruction::FCmp:
            case Instruction::Switch:
            case Instruction::Br:
            case Instruction::IndirectBr:
                break;
            default:
                for(User::op_iterator OI =I->op_begin(),OE=I->op_end();OI!=OE;++OI){
                    taint = getTaint(*OI,SE)>taint?getTaint(*OI,SE):taint;
                }
                break;
        }
        if(taint && !MD){
            STA_DEBUG("taint instruction ="<<*I<<"\n");
            changed |=setTaint(I,SE,taint);
        }
    }
    return changed;
}

//backward propogation
bool STaint::backwardTaint(llvm::Function *F,ScalarEvolution &SE) {
    //TODO:Klotski backwardTaint
    return false;
}

bool STaint::annotateTaint(llvm::Function *F) {
//    bool changed = false;
//    StringRef FuncName = F->getName();
    //TODO: Klotski annotateTaint
    return false;

}

bool STaint::taintCaller(llvm::Function *F,ScalarEvolution &SE) {
    int tainted = CLEAN_TAG;

#ifdef DO_FORWARD
    std::string Id;
#ifndef FIND_SS
    Id = getStructId(F->getReturnType(), CurrentModule);
    // no need to check if the return type is sensitive
    if (!Id.empty() && SStructs.count(Id))
        return false;
#endif //FIND_SS
    Id = getRetId(F);
    if (CurrentGContext.count(Id))
        tainted = CurrentGContext[Id];
#endif //DO_FORWARD

    if(!tainted)
        return false;

    SmallPtrSet<Function*,4> Visited;
    CallInstSet &CIS = Ctx->Callers[F];
    for(CallInst *CI: CIS){
        Function *Fn = CI->getFunction();

        if(!Visited.insert((Fn)).second)
            continue;

        if(!CurrentCallStack.insert(Fn).second)
            continue;

        runFunction(Fn,SE,true);
    }

    return false;
}
bool STaint::runFunction(llvm::Function *F,ScalarEvolution &SE, bool checkCaller) {
    bool changed = true, ret = false;

#ifdef DO_FORWARD
    for(Argument &A :F->args()){
        std::string Id = getStructId(A.getType(),CurrentModule);
        if(!Id.empty() && SStructs.count(Id)){
            setTaint(&A,SE,SAFE_TAG);
        }
    }
#endif//DO_FORWARD

    while(changed){
        changed = false;
#ifdef DO_FORWARD
        changed |= forwardTaint(F,SE);
#endif

#ifdef DO_BACKWARD
        changed |= backwardTaint(F);
#endif

        ret |= changed;
    }

    if(checkCaller)
        taintCaller(F,SE);

    return ret;
}

void STaint::contextReset(Function*F) {
    CurrentLContext.clear();
    CurrentGContext.clear();
    CurrentCallStack.clear();
    CurrentCallStack.insert(F);
}

bool STaint::runOnFunction(llvm::Function *F, ScalarEvolution *SE) {
    contextReset(F);
    return runFunction(F,*SE,true);
}

static void PrintStat(raw_ostream &OS, Statistic &S) {
    OS << format("%8u %s - %s\n", S.getValue(), S.getName(), S.getDesc());
}
void STaint::dumpWrites() {
    outs() << "[dumpWrites]\n";

    PrintStat(outs(), NumFunctions);
    PrintStat(outs(), NumWrites);
    PrintStat(outs(), NumSafeWrites);
    PrintStat(outs(), NumUnsafeWrites);
    PrintStat(outs(), NumGEP);
    PrintStat(outs(), NumSafeGEP);
    PrintStat(outs(), NumUnsafeGEP);
    PrintStat(outs(), NumUnsafeNCGEP);

    outs() << "[End of dumpWrites]\n";
}

#undef TM
