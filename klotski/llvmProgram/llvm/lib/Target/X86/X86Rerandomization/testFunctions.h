//
// Created by alax on 4/16/17.
//
#ifndef LLVM_FINDTestFunc_H
#define LLVM_FINDTestFunc_H


#include "X86.h"
#include "X86Subtarget.h"
#include "llvm/Pass.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineMemOperand.h"
using namespace llvm;
//static bool isMovInstrFunctFound(const int opcode){
//    return  opcode == X86::MOV64rr || //1724
//                opcode == X86::MOV64rm||       //1723
//                opcode == X86::MOV64mr||
//                opcode == X86::MOV64mi32 ||
//                opcode == X86::MOV32rr ||
//                opcode == X86::MOV32rm ||
//                opcode == X86::MOV32ri ||
//                opcode == X86::MOV32mr ||
//                opcode == X86::MOV8mi ||
//                opcode == X86::MOV8ri ||
//                opcode == X86::MOVSSmr||
//                opcode == X86::MOV64ri ||
//                opcode == X86::MOV32mi ;
//}
static inline bool isADD(const int opcode){
    return (opcode >= X86::ADD16i16 && opcode<=X86::ADDSSrr);
}
static inline bool isSUB(const int opcode){
    return(opcode >=X86::SUB16i16 && opcode<=X86::SUBSSrr);
}
static inline bool isArith(const int opcode){
    return isADD(opcode)||
           isSUB(opcode);
}
static inline bool isCMP(const int opcode){
    return (opcode >=X86::CMP16i16 && opcode<=X86::CMP8rr);
}
static inline bool isMOV(const int opcode){
    return opcode >= X86::MOV16ao16 && opcode <= X86::MOVZX64rr8;
}
static inline bool isPOP(const int opcode){
    return opcode >= X86::POP16r && opcode <= X86::POPSS32;
}
static inline bool isPush(const int opcode){
    return opcode >= X86::PUSH16i8 && opcode <= X86::PUSHi32;
}
static inline bool isPOPorPush(const int opcode){
    return isPOP(opcode)||isPush(opcode);
}
static inline bool isLD_F80m(const int opcode){
    return opcode == X86::LD_F80m;
}
static inline bool isINCorDEC(const int opcode){
    return (opcode>=X86::DEC16m && opcode <= X86::DEC8r) ||
            (opcode>=X86::INC16m && opcode <= X86::INC8r);
}

static inline bool isLEA(const int opcode){
    return (opcode >=X86::LEA16r && opcode <= X86::LEA64r);
}
static inline bool isRET(const int opcode){
    return(opcode >=X86::RET&& opcode<=X86::RETW);
}
static inline bool isTailJMP(const int opcode){
    return(opcode >=X86::TAILJMPd&& opcode<=X86::TAILJMPr64_REX);
}

static bool hasControlFlow(const MachineInstr &MI){
    return MI.getDesc().isBranch() ||
            MI.getDesc().isCall() ||
            MI.getDesc().isReturn() ||
            MI.getDesc().isIndirectBranch();
}

//mi
//mr
//rm
static int findMemOprandFirstIndex(const MachineInstr &MI){
    const MCInstrDesc &Desc =MI.getDesc();
    int AddrOffset = X86II::getMemoryOperandNo(Desc.TSFlags);
    if(AddrOffset >=0){
        AddrOffset +=X86II::getOperandBias(Desc);
    }
    return AddrOffset;
}
#endif //LLVM_FINDLRINSTRUCTS_H