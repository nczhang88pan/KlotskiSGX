//
// Created by alax on 4/15/17.
//

#include "testFunctions.h"
#include "handleLEARSPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#define DEBUG_TYPE "machinecount"
#define isStackPageAlign 0
FunctionPass *llvm::handleLEARSPPass() {
    return new handleLEARSP();
}
char handleLEARSP::ID = 0;

bool handleLEARSP::processLEAinstr(MachineBasicBlock::iterator &I) {
    MachineOperand &target=I->getOperand(0);
//    MachineOperand &baseR=I->getOperand(1);

    if(target.isReg() && target.getReg() == X86::R13){
       // I->print(errs());
       //&& target.isReg() &&target.getReg() ==X86::R13){
//        I->print(errs());
//        //baseR.setReg(X86::R13);
        return true;
    }
    return false;
}
bool handleLEARSP::processBasicBlock(MachineFunction &MF,MachineFunction::iterator &MFI) {
    bool isModified=false;
    for(MachineBasicBlock::iterator BBI = MFI->begin(),BBE = MFI->end(); BBI!=BBE;BBI++){
        if(isLEA(BBI->getOpcode())){
            isModified |= processLEAinstr(BBI);
        }
    }
    return isModified;
}

static bool handleLeaRSPInst(MachineBasicBlock::iterator FirstLea,MachineBasicBlock::iterator SecondInline){

    const TargetInstrInfo *TII = FirstLea->getParent()->getParent()->getSubtarget().getInstrInfo();
//    FirstLea->print(errs());
//    SecondInline->print(errs());


    unsigned OpNo = InlineAsm::MIOp_FirstOperand;
//    unsigned Reg_1_input;
    unsigned Reg_0_output;
    int Val = 1;
    for (; Val; --Val) {
        if (OpNo >= SecondInline->getNumOperands()) break;
        unsigned OpFlags = SecondInline->getOperand(OpNo).getImm();
        OpNo += InlineAsm::getNumOperandRegisters(OpFlags) + 1;
    }
    ++OpNo;  // Skip over the ID number.

//    MachineOperand &MO_1 = SecondInline->getOperand(OpNo);//$1
//    if(MO_1.getType()==MachineOperand::MO_Register){
//        Reg_1_input = MO_1.getReg();
//    }


    OpNo = InlineAsm::MIOp_FirstOperand+1;
    MachineOperand &MO_0 = SecondInline->getOperand(OpNo);//$0
    if(MO_0.getType()==MachineOperand::MO_Register){
        Reg_0_output = MO_0.getReg();
    }
    int baseIndex = findMemOprandFirstIndex(*FirstLea);
    if(FirstLea->getOperand(0).getReg()!=Reg_0_output)
        return false;
    MachineInstrBuilder MIB= BuildMI(*FirstLea->getParent(),std::next(FirstLea),std::next(FirstLea)->getDebugLoc(),TII->get(X86::LEA64r),Reg_0_output);
//    MIB->addOperand(MachineOperand::CreateReg(X86::R13,true));
    for(int i=0;i<5;i++){
        MIB->addOperand(FirstLea->getOperand(baseIndex+i));
    }
    MIB->getOperand(baseIndex).setReg(X86::R13);

//    std::prev(FirstLea)->getOperand(1).setReg(X86::R13);
//    errs()<<"---------start-----------\n";
//    std::prev(FirstLea)->print(errs());
//    FirstLea->print(errs());
//    SecondInline->print(errs());
//    std::next(SecondInline)->print(errs());
//    errs()<<"-----------end---------\n";
    return true;

}
bool handleLEARSP::instrumentCPIAndGlobalAddress(MachineBasicBlock::iterator &I) {
    unsigned firstMMOperand = findMemOprandFirstIndex(*I);
    MachineBasicBlock *MBB = I->getParent();

    BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::PUSHF64));
    //MOV target, %r14
    MachineInstrBuilder MIB = BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::MOV64ri),X86::R14);
    MIB->addOperand(I->getOperand(firstMMOperand+3));

    BuildMI(*MBB,I,I->getDebugLoc(),TII->get(X86::CALL64m)).addReg(X86::R15)
            .addImm(0).addReg(0).addImm(0x60).addReg(0);

    BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::POPF64));

    if(I->getOperand(firstMMOperand).isReg() && I->getOperand(firstMMOperand).getReg()==X86::NoRegister){
        I->getOperand(firstMMOperand).setReg(X86::R14);
        I->getOperand(firstMMOperand+3).ChangeToImmediate(0);
        return true;
    } else{
        if(I->getOperand(firstMMOperand+2).getReg()==X86::NoRegister && I->getOperand(firstMMOperand+1).getImm()==1){
            I->getOperand(firstMMOperand+2).setReg(X86::R14);
            I->getOperand(firstMMOperand+3).ChangeToImmediate(0);
            return true;
        } else{
            I->print(errs());errs()<<"find instruciton\n";
            I->getParent()->getParent()->print(errs());
            errs()<<"original func\n";
            I->getParent()->getParent()->getFunction()->print(errs());
            errs()<<__func__<<" Register is not noregister\n";
//            exit(-1);
        }
    }
}
bool handleLEARSP::instrumentRelativeAddress(MachineBasicBlock::iterator &I) {
    unsigned firstMMOperand = findMemOprandFirstIndex(*I);
    MachineBasicBlock *MBB = I->getParent();


    BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::PUSHF64));

    MachineInstrBuilder MIB = BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::MOV64ri),X86::R14);
    MIB->addOperand(I->getOperand(firstMMOperand+3));

    //RORX R14 R14>>12
//    BuildMI(*MBB,I,I->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//            .addReg(X86::R14)
//            .addImm(11);

//    BuildMI(*MBB,I,I->getDebugLoc(),TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//            .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0);
    BuildMI(*MBB,I,I->getDebugLoc(),TII->get(X86::CALL64m))
            .addReg(X86::R15).addImm(0).addReg(0).addImm(0x60).addReg(0);
//    //RORX R14 R14>>52
//    BuildMI(*MBB,I,I->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//            .addReg(X86::R14)
//            .addImm(53);

    BuildMI(*MBB,*I,I->getDebugLoc(),TII->get(X86::POPF64));

    I->getOperand(firstMMOperand).setReg(X86::R14);
    I->getOperand(firstMMOperand+3).ChangeToImmediate(0);
    return true;
}

bool handleLEARSP::runOnMachineFunction(MachineFunction &MF){
    TII = MF.getSubtarget().getInstrInfo();
    TRI = MF.getSubtarget().getRegisterInfo();
    bool modified = false;
    if(MF.getName()=="main"){ return false;}
    if(MF.getName()=="fillPagetable") return false;

    SmallVector<MachineBasicBlock::iterator,8> globalFunctionSet;

    for(MachineFunction::iterator MBBI = MF.begin(), MBBE=MF.end();MBBI!=MBBE;++MBBI){
        for(MachineBasicBlock::iterator BBI = MBBI->begin(),BBE = MBBI->end(); BBI!=BBE;BBI++){
            if(isLEA(BBI->getOpcode())){//is lea
//                MachineOperand &target=BBI->getOperand(0);
//                MachineOperand &baseR=BBI->getOperand(1);
//                if(baseR.isReg() && baseR.getReg() == X86::RSP){ //baseR is rsp
//                    MachineBasicBlock::iterator nextInst=std::next(BBI);
//                    if(nextInst==BBE) continue;
//
//                    //MBBI->print(errs());
//                    //nextInst->print(errs());
//                    if(nextInst->getOpcode() == TargetOpcode::INLINEASM){ //the next instruction is an inline one
//
//#if isStackPageAlign
//                        if(handleLeaRSPInst(BBI,nextInst)){
//                            errs()<<"cout nextInst\n";
//                            nextInst->print(errs());
//                            MBBI->erase(nextInst);
//                        }
//#endif //isStackPageAlign
//                    }
//
//                } else if (baseR.isReg() && baseR.getReg() == X86::RIP){
//                    errs()<<"find special RIP\n";
//                    BBI->print(errs());errs()<<"\n";
//                }
            } else if(BBI->mayLoadOrStore() && !isPOPorPush(BBI->getOpcode())){
                if(BBI->isInlineAsm()) continue;
                int first = findMemOprandFirstIndex(*BBI);
                MachineOperand &baseR = BBI->getOperand(first);
                if(baseR.isReg() && baseR.getReg() == X86::RIP){
//                    errs()<<__func__<<" ";BBI->print(errs());
                    //   instrumentRelativeAddress(BBI);
                } else{
                    MachineOperand &offset = BBI->getOperand(first+3);
                    if(offset.isCPI()||offset.isGlobal()||offset.isJTI()){
                        instrumentCPIAndGlobalAddress(BBI);
                    }
                }
            } else if(BBI->isCall()){
//                if(BBI->getDesc().isCall()){
//                    MachineOperand &mo = BBI->getOperand(0);
//                    if(mo.isGlobal() && mo.getGlobal()->getName().startswith("addressDereference64")){
//
//
//                        BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::JMP64m))
//                                .addReg(X86::R15)
//                                .addImm(0).addReg(0).addImm(0x40)
//                                .addReg(0);
//                        BBI->print(errs());errs()<<"we have find the addressDereference64_1\n";
//
//                    }
//                }

                //Pan-pathOram: we will handle call instruction at the MCInstLower
//                MachineOperand &mo = BBI->getOperand(0);
//                if(!mo.isReg()){
//                    BBI->print(errs());errs()<<"BBI->none Reg\n";
//                    BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::MOV64ri),X86::R14)
//                            .add(mo);
//                    //RORX R14 R14>>12
//                    BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//                            .addReg(X86::R14)
//                            .addImm(11);
//                    BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                            .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0);
//                    //RORX R14 R14>>52
//                    BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//                            .addReg(X86::R14)
//                            .addImm(53);
//                    MachineInstrBuilder MIB;
//                    if(isTailJMP(BBI->getOpcode())){
//                        if(BBI->getFlag(MachineInstr::FrameDestroy)){
//                            BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::TAILJMPr64))
//                                    .addReg(X86::R14).setMIFlag(MachineInstr::FrameDestroy);
//                        } else{
//                            BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::TAILJMPr64))
//                                    .addReg(X86::R14);
//                        }
//
//                    } else{
//                        BuildMI(*MBBI,*BBI,BBI->getDebugLoc(),TII->get(X86::CALL64r))
//                                .addReg(X86::R14);
//                    }
//                    globalFunctionSet.push_back(BBI);
//                }
            }
        }
    }
    if(globalFunctionSet.size()){
        modified=true;
    }
    while(globalFunctionSet.size()){
        MachineBasicBlock::iterator temp=globalFunctionSet.pop_back_val();
        temp->eraseFromParent();
    }
    return  modified;
}

static RegisterPass<handleLEARSP> X("handleLEARSP","replace the rsp in lea (rsp+offset),generalRegister with rbp");
