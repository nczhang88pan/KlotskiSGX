//
// Created by alax on 4/15/17.
//

#ifndef LLVM_FINDLRINSTRUCTS_H
#define LLVM_FINDLRINSTRUCTS_H
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

namespace {
    class handleLEARSP: public MachineFunctionPass {
    public:
        static char ID;
        handleLEARSP(): MachineFunctionPass(ID){}
        bool runOnMachineFunction(MachineFunction &MF) override;

    private:
        const TargetInstrInfo *TII;
        const TargetRegisterInfo *TRI;
        bool processBasicBlock(MachineFunction &MF,MachineFunction::iterator &MFI);
        bool processLEAinstr(MachineBasicBlock::iterator &I);

        bool instrumentLEA(MachineBasicBlock::iterator &I);
        bool instrumentRelativeAddress(MachineBasicBlock::iterator &I);
        bool instrumentCPIAndGlobalAddress(MachineBasicBlock::iterator &I);

    };
}

#endif //LLVM_FINDLRINSTRUCTS_H
