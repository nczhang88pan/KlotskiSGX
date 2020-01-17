//
// Created by alax on 7/21/17.
//

#ifndef LLVM_DATAANALYSIS_H
#define LLVM_DATAANALYSIS_H

#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include <unordered_map>
#include <cstdio>
#include <iostream>
#include <vector>
#include <map>
#include <sstream>
#include <string>
#include <iomanip>
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/LoopInfo.h"
#include <unordered_set>

using namespace std;
namespace llvm{
    static std::vector<std::string> safeFunctions = {
//            "__sin"
//            //emfloat.c
//            "IsMantissaZero",
//            "SetInternalFPFZero",
//            "ShiftMantRight1",
//            "Sub16Bits",
//            "Add16Bits",
//            "SetInternalFPFNaN",
//            "choose_nan",
//            "ShiftMantLeft1",
//            "SetInternalFPFInfinity",
//            "StickyShiftRightMant",
//            "normalize",
//            "Int32ToInternalFPF",//nbench0.c
//            "set_request_secs",
//            "getscore",//nbench1.c
//            "LoadAssign",
//            "en_key_idea",
//            "NumSift",
//            "ToggleBitRun",
//            "FlipBitRun",
//            "CopyToAssign",
//            "calc_minimum_costs",
//            "first_assignments",
//            "second_assignments",
//            "mul",
//            "inv",
//            "SetCompBit",
//            "GetCompBit",
//            "zero_changes",
//            "move_wt_changes",
//            "do_out_error",
//            "adjust_mid_wts",
//            "do_mid_error",
//            "adjust_out_wts",
//            "worst_pass_error",
//            "get_xyinout",
//            "get_numpats",
//            "get_val5",
//            "get_val7",
//            "lubksb",
//            "de_key_idea",
//            "NumHeapSort",
//            "NumHeapSort_non_optimized",
//            "Assignment",
//            "cipher_idea",
//            "do_back_pass",
//            "check_out_error",
//            "LUFreeMem",
//            "LoadNumArrayWithRand",
//            "stradjust",
//            "fabs",
//            "lusolve",
//            "pow",
//            "cos",
//            "sin",
//            "thefunction",
//            "TrapezoidIntegrate",
//            "read_data_mem",//misc.c
//            "randnum",
//            "randwc",
//            "abs_randwc",
//            "randomize_wts",
//            //sysspec.c
//            "mspace_malloc_init_pan",
//            "mspace_track_large_chunks",
//            "destroy_mspace",
//            "mspace_footprint",
//            "mspace_max_footprint",
//            "mspace_footprint_limit",
//            "mspace_set_footprint_limit",
//            "mspace_usable_size",
//            "set_inited",
//            "AddMemArray",
//            "RemoveMemArray",
//            "MoveMemory",
//            "InitMemArray",
//            "TicksToSecs",
//            "TicksToFracSecs",
//            "init_bins",
//            "init_top",
//            "mmap_alloc",
//            "segment_holding",
//            "mmap_resize",
//            "init_user_mstate",
//            "AllocateMemory",
//            "FreeMemory",
//            "MoveMemory"
    };
    typedef std::vector<BitVector> BitVectorList;
    typedef std::unordered_map<Value*,Value*> ShadowMap;

    /* Stores the IN and OUT sets for a basic block. Also a variable to store the temporary output of the transfer function */
    struct BlockResult {
        bool killed;
        ShadowMap GlobalorConstantValue;
        std::unordered_map<Value*,PHINode *> phiForShadowValue;
        BitVector in;
        ShadowMap inObjs;
        ShadowMap inShadow;

        BitVector need;
        ShadowMap needObjs;
        ShadowMap subBBneedObjs;

        BitVector gen;
        ShadowMap genObjs;

        BitVector out;
        ShadowMap outObjs;
        ShadowMap outShadow;

    };
    typedef struct BlockResult LoopResult;

/* Result of pass on a function */
    struct DataFlowResult {
        /* Mapping from basic blocks to their results */
        std::map<BasicBlock*, BlockResult*> result;
        std::map<Loop*,LoopResult*> loopResults;

        /* Mapping from domain elements to indices in bitvectors
           (to figure out which bits are which values) */
        std::map<void*, int> domainToIndex;

        bool modified;
    };
    bool isfuncNeedHandle(StringRef functionName);

/* Basic Class for Data flow analysis. Specific analyses must extend this */
    class DataFlow {
    public:

        DataFlow() {}
        ~DataFlow();
        DataFlowResult *init(Function &F,LoopInfo &LI,DominatorTree *DT,std::vector<Value*> &noneRandomPointSet);
        BasicBlock *splitEdge(BasicBlock *BB, BasicBlock *Succ, DominatorTree *DT,LoopInfo *LI);
        void initInAndOut(Function &F);
        void printResults(DataFlowResult* dataFlowResult,BasicBlock *basicBlock);
        void hanldInstructionToBuildUpNeedAndGen(BasicBlock::iterator &I,BlockResult &blockResult,std::vector<Value*> &noneRandomPointSet);
        LoopResult *calculateLoopInAndOut(LoopInfo &LI,Loop &loop);
        LoopResult *initLoopResult(LoopInfo &LI,Loop *loop);
        Value* getSRCPointerFromConstant(Instruction* instruction);
        Value* findRequiredPointer(Value* pointer,BlockResult &blockResult);
        bool mergeInAndUpdateOut(LoopInfo &LI,BasicBlock * basicBlock, SmallVector<BlockResult*,4> &prevBlockResultSet,BlockResult *blockResult);

        /* Applying Meet Operator */
        BitVector applyMeetOp(BitVectorList inputs);

        /* Apply analysis on Function F */
        DataFlowResult run(Function &F, std::vector<void*> domain,
                           BitVector boundaryCond, BitVector initCond);
        static bool isRandomPoint(Instruction *I,Value *calledFunction,std::vector<Value*> &noneRandomPointSet);

    private:
        class Expression {
        public:
            Value * v1;
            Value * v2;
            Instruction::BinaryOps op;
            Expression (Instruction * I);
            bool operator== (const Expression &e2) const;
            bool operator< (const Expression &e2) const;
            std::string toString() const;
        };
        std::vector<Value *> pointerList;
        DataFlowResult dataFlowResult;
        std::unordered_set<Value *> pointerUsedbyStoreAndLoad;
    };

    static std::set<std::string> isExcludeFunctions = {
//            "sprintf","snprintf","puts","printf_sgx"
    };

    static inline bool isInList(std::set<std::string> Set, Value *F) {
        return Set.count(F->getName().str()) > 0;
    }

    static bool isExcludeFunction(Value *F){
        return isInList(isExcludeFunctions, F);
    }
}


#endif //LLVM_DATAANALYSIS_H
