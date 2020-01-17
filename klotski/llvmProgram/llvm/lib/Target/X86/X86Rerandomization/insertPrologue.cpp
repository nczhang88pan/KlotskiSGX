//
// Created by alax on 4/13/17.
//
#include "testFunctions.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/MC/MCContext.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/IR/InstIterator.h"
#include "X86MachineFunctionInfo.h"
#include <unordered_map>
#define PanDebug 0
#define SGXBASIC 1
#define DEBUG_TYPE "InsertEANDPrologue"
using namespace llvm;
#define isStackPageAlign 0

namespace {

    class InsertEANDPrologue:public MachineFunctionPass{
    public:
        static char ID;
        InsertEANDPrologue():MachineFunctionPass(ID){
            initializeInsertEANDProloguePass(*PassRegistry::getPassRegistry());
        };
        bool runOnMachineFunction(MachineFunction &MF) override;
        //processBasicBlock
        bool handlePrologue(MachineFunction::iterator MFI,MachineBasicBlock::iterator proEnd);
        bool handleBlock(MachineFunction::iterator MFI);
        bool handleEPrologue(MachineBasicBlock &MBB);

        //processInstruction
        bool handleInstruction(MachineBasicBlock &MBB,MachineBasicBlock::iterator MBI);
        bool insertDereferenceInstr(MachineBasicBlock &MBB,MachineBasicBlock::iterator MBI);
        bool handleControlFlowInstruction(MachineBasicBlock &MBB,MachineBasicBlock::iterator MBI);

        //processStack
        bool alignStack(MachineBasicBlock &MBB,MachineBasicBlock::iterator &MBI,MachineBasicBlock::iterator &prolEnd);
        bool epalignStack(MachineBasicBlock &MBB);
        virtual bool doInitialization(Module &module);
        void getAnalysisUsage(AnalysisUsage &AU) const override;
        bool checkWhetherWeCanIgnoreTheEAandPrologue(Function &MF);
        bool instrumentOverArgumentsLeafFunction(MachineFunction &MF);


    private:
        const TargetInstrInfo *TII;
        const TargetRegisterInfo *TRI;
        std::unordered_map<const Function*,const Function*> leafMachineFunctionSets;
        MachineModuleInfo *ModuleInfor = nullptr;
        std::unordered_map<int,int> StackValueNeedMov; //the frameIndex and its num
    };

}

char InsertEANDPrologue::ID = 0;
INITIALIZE_PASS_BEGIN(InsertEANDPrologue, "insertEandPrologue-module",
                      "insertEandPrologue instruction insert.", false, true)
    INITIALIZE_PASS_DEPENDENCY(MachineModuleInfo)
INITIALIZE_PASS_END(InsertEANDPrologue, "insertEandPrologue-module",
                    "insertEandPrologue instruction insert.", false, true)

bool InsertEANDPrologue::checkWhetherWeCanIgnoreTheEAandPrologue(Function &F) {

    //check it again
    for(inst_iterator i=inst_begin(F),e=inst_end(F);i!=e;++i){
        if(CallInst *CI = dyn_cast<CallInst>(&*i)){
            if(CI->isInlineAsm()) continue;
            if(CI->hasName() && CI->getName().startswith("llvm.")) continue;
            return false;
        }
    }
    if(F.isLocalLinkage(F.getLinkage())){
       return true;
    }
    return false;
}

bool InsertEANDPrologue::doInitialization(Module &module) {
    for (Function &F : module){
        if(checkWhetherWeCanIgnoreTheEAandPrologue(F)){
            leafMachineFunctionSets[&F]=&F;
        }
    }
    return false;
}
void InsertEANDPrologue::getAnalysisUsage(AnalysisUsage &AU) const {
    AU.setPreservesAll();
    AU.addRequired<MachineModuleInfo>();
    AU.addPreserved<MachineModuleInfo>();

    FunctionPass::getAnalysisUsage(AU);
    MachineFunctionPass::getAnalysisUsage(AU);
}

#define printPOPandPUSH() \
    if(popAndpushInstrExistInFunctionBody.size())\
        errs()<<"pop and push exit in function body\n";\
    for(auto it:popAndpushInstrExistInFunctionBody){\
        it->print(errs());\
    }\

#define printPrilogue()\
    errs()<<" --------------the prilogue start at:------------\n";\
    for(auto itr:epilogueStartInstrSet){\
        errs()<<"BB:"<<itr.first->getName()<<"\n";\
        itr.second->print(errs());\
    }\
    errs()<<" --------------the prilogue end at:------------\n";\
    for(auto itr:epilogueTerInstrSet){\
        errs()<<"BB:"<<itr.first->getName()<<"\n";\
        itr.second->print(errs());\
    }\


//first handle call and then branch instruction and finnal else
bool InsertEANDPrologue::handleControlFlowInstruction(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBI) {
    //Todo handle control flow instructions
//    MachineFunction &MF = *MBB.getParent();
//    const DebugLoc &DL = MBI->getDebugLoc();

    if(MBI->getDesc().isCall()){
        return false;
//       if( MBI->getOperand(0).isGlobal()){
//           //global->R14
//           BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::MOV64ri),X86::R14)
//                   .addGlobalAddress(MBI->getOperand(0).getGlobal());
//           //R14>>12 -> R14
//           BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//                   .addReg(X86::R14)
//                   .addImm(12);
//
//       } else if(MBI->getOperand(0).isReg()){
//           int offset = findMemOprandFirstIndex(*MBI);
//           if(offset>0){
//               errs()<<__func__<<"call using call[mem] module which needs double-dereference\n";
//               MBI->print(errs());
//               //Todo double-dereference of Call [mem]
//           } else{
//               // target register >> 12 -> R14
//               BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//                       .addReg(MBI->getOperand(0).getReg())
//                       .addImm(12);
//           }
//       } else{
//           errs()<<__func__<<" call operand0 is not global or reg\n";
//           MBI->print(errs());
//           return false;
//       }
//        //R14+offset->R14
//        BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0);
//        //RORX R14 R14>>52
//        BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
//                //.addReg(X86::RSP).addImm(1).addReg(0).addImm(-8).addReg(0)
//                .addReg(X86::R14)
//                .addImm(52);
//        //Call R14
//        MachineInstrBuilder MIB=BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::CALL64r)).addReg(X86::R14);
//        MBB.erase(MBI);


        //instruction is Indirect
    }else if(MBI->getDesc().isBranch()){
        if(!MBI->getOperand(0).isMBB()){
            errs()<<__func__<<"!!!!!!!!!!!!!!!!!!!!target is not MBB\n";
            MBI->print(errs());
        }

        if(MBI->getDesc().isIndirectBranch()){
            errs()<<__func__<<"!!!!!!!!!!!!!!!!!!!!isIndirectBranch:\n";
            MBI->print(errs());
            //instruction is UnconditionalBranch
        } else if(MBI->getDesc().isUnconditionalBranch()){
            //instruction is ConditionalBranch
        } else if(MBI->getDesc().isConditionalBranch()){
            //instruction is ret
        }
    } else if(MBI->getDesc().isReturn()){

    } else{
        errs()<<__func__<<" control flow instruction is not ret/IB/UB/CB\n";
        MBI->print(errs());
    }
    return false;

}
bool InsertEANDPrologue::insertDereferenceInstr(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBI) {
     int opcode = MBI->getOpcode();
    if(isPOPorPush(opcode)){
        return false;
    }
    int baseIndex = findMemOprandFirstIndex(*MBI);
    if(baseIndex<0){
        return false;
    }
    MachineOperand &base = MBI->getOperand(baseIndex);
    if(base.isReg() && base.getReg()!=X86::RSP && base.getReg()!=X86::R15 &&base.getReg()!=X86::R15D){
        //How many instruction are inserted with Dereference instructions.
        //MBI->print(errs());

        //BuildMI(MBB,MI,MI.getDebugLoc(),TII->get(X86::FNOP));
        //lea (%eax) %r14
        MachineInstrBuilder MIB = BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::LEA64r),X86::R14);
        for(int i=0;i<5;i++){
            MIB->addOperand(MBI->getOperand(baseIndex+i));
        }
        //RORX R14 R14>>11
        BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
                .addReg(X86::R14)
                .addImm(11);

        BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0);
        //RORX R14 R14>>53
        BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
                //.addReg(X86::RSP).addImm(1).addReg(0).addImm(-8).addReg(0)
                .addReg(X86::R14)
                .addImm(53);

        //if is call [MEM], we need double dereference
        if(MBI->isCall()){
            BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::MOV64rm),X86::R14)
                    .addReg(X86::R14).addImm(1).addReg(0).addImm(0).addReg(0);
            BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
                    .addReg(X86::R14)
                    .addImm(11);
            BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
                    .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0);
            BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::RORX64ri),X86::R14)
                    .addReg(X86::R14)
                    .addImm(53);
            BuildMI(MBB,*MBI,MBI->getDebugLoc(),TII->get(X86::CALL64r),X86::R14);
            MBB.erase(MBI);
            return true;
        }
        MBI->getOperand(baseIndex + 0).setReg(X86::R14);
        MBI->getOperand(baseIndex + 1).setImm(1);
        MBI->getOperand(baseIndex + 2).setReg(0);
        MBI->getOperand(baseIndex + 3).ChangeToImmediate(0);

        //MIB.getInstr()->print(errs());
        return true;
    }
    return false;
}

bool InsertEANDPrologue::handleInstruction(MachineBasicBlock &MBB,MachineBasicBlock::iterator MBI) {
    //replace RSP register with RBP
    bool isModified= false;
    unsigned test=0;
    if(isLEA(MBI->getOpcode())){

    }
    if(MBI->mayLoadOrStore()){
        isModified=insertDereferenceInstr(MBB,*MBI);
        test++;
    }
    if(hasControlFlow(*MBI)){
        isModified=handleControlFlowInstruction(MBB,MBI);
        test++;
    }
//    if(test==2){
//        errs()<<__func__<<":\n";
//        MBI->print(errs());
//        errs()<<"         load from mm\n";
//    }
    return isModified;
}
bool InsertEANDPrologue::instrumentOverArgumentsLeafFunction(MachineFunction &MF) {
    bool modified = false;
    int stackSize = MF.getFrameInfo().getStackSize();
    for(MachineFunction::iterator MBBI = MF.begin(), MBBE=MF.end();MBBI!=MBBE;++MBBI){
        for(MachineBasicBlock::iterator BBI = MBBI->begin(),BBE = MBBI->end(); BBI!=BBE;BBI++){
            int opcode = BBI->getOpcode();
            if(BBI->mayLoadOrStore()){
                if(!isPOPorPush(opcode) && !BBI->isInlineAsm()){
                    int base=findMemOprandFirstIndex(*BBI);
                    if(BBI->getOperand(base).isReg() && BBI->getOperand(base).getReg() == X86::RSP){
                        int frameIndex = BBI->getOperand(base+3).getImm();
                        if(frameIndex>stackSize){
                            frameIndex -= 8*2;
                            BBI->getOperand(base+3).setImm(frameIndex);
                            modified = true;
                        }
                    }
                }
            }

        }
    }
    return modified;
}

bool InsertEANDPrologue::alignStack(MachineBasicBlock &MBB, MachineBasicBlock::iterator &MBI,MachineBasicBlock::iterator &prolEnd) {
    MachineFunction &MF = *MBB.getParent();
    const Function *F = MF.getFunction();
    const DebugLoc &DL = MBI->getDebugLoc();
//    X86MachineFunctionInfo *X86FI = MF.getInfo<X86MachineFunctionInfo>();

    MachineInstrBuilder MIB;
    const BasicBlock *LLVM_BB=MBB.getBasicBlock();
    const int stackSizeAll = MF.getFrameInfo().getStackSize();

    //we first calculate the real allocated stack size in the entry block
    int realStackSize=0;
    for(MachineBasicBlock::iterator MBBI=MBB.begin(),MBBE=MBB.end();MBBI!=MBBE;MBBI++){
        if(!MBBI->getFlag(MachineInstr::FrameSetup))continue;
        int opcode = MBBI->getOpcode();
        if(isPush(opcode)){
            realStackSize +=8;
        } else if(isSUB(opcode) && MBBI->getOperand(0).isReg() && MBBI->getOperand(0).getReg()==X86::RSP){
            realStackSize += MBBI->getOperand(2).getImm();
        }
    }
    if(realStackSize!=stackSizeAll){
        MBB.print(errs());
        errs()<<MBB.getParent()->getName()<<" stack size does not suit for stackSize\n";
        errs()<<"realStackSize: "<<realStackSize<<" stackSize: "<<stackSizeAll<<"\n";
    }

#if SGXBASIC
    //if the size equal 0 or it is a leafFunction
    if(stackSizeAll==0 || leafMachineFunctionSets[F]){
        //BuildMI(MBB,MBI,DL,TII->get(X86::PUSH64r)).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
        BuildMI(MBB,MBI,DL,TII->get(X86::SUB64ri32),X86::R13).addReg(X86::R13).addImm(8+realStackSize).setMIFlag(MachineInstr::FrameSetup);
        if(F->arg_size() > 6){
            instrumentOverArgumentsLeafFunction(MF);
        }
        return true;
    }
#endif
    int stackSize = realStackSize;

    int newStackSize = stackSize + 8;
//    if(stackSizeAll + 8 > 4096){
//        errs()<<"This function frame size is bigger than 4096.\n";
//        //return false;
//    }

    //measure basic block
    //if  (RBP&0xfff >= stackSize + 16)
    //             goto continueMBB
    //MBB:
    //    MOV  RBP R14
    //    SAL  R14 4
    //    CMP  stacksize<<4, R14W
    //    JAE   ReserveMBB
    //AlignMBB
    //    SHR R14 16                --> SHR R14 15
    //    ADD (R15D + R14D*8 -8) R14D    [R14-1] + R14-1 +1  --> ADD (R15D + R14D*8 -16) R14D
    //    SHL 12 R14                --> SHL 11 R14
    //    LEA R14 RSP
    //    PUSH rbp
    //    AND rbp, (%r15)
    //    RBP = RBP-(stackSize+16) //we do not need to minus the RET index
    //    JMP ContinueMBB //or checkMBB
    //ReserveMBB
    //    PUSH rbp
    //    RBP = RBP - (stackSize +24)
    //[optional]CheckMBB
    //    MOV RBP, R14
    //    SUB RSP, RBP
    //    AND 0xfff, R14
    //    je  ContinueMBB
    //    jmp 0
    //ContinueMBB:
    //    [rest of original instruction//RSP+8]
    MachineBasicBlock *AlignMBB = MF.CreateMachineBasicBlock(LLVM_BB);
    MachineBasicBlock *ReserveMBB = MF.CreateMachineBasicBlock(LLVM_BB);
    MachineBasicBlock *ContinueMBB = MF.CreateMachineBasicBlock(LLVM_BB);

    MachineFunction::iterator MBBIter = std::next(MBB.getIterator());
    MF.insert(MBBIter,AlignMBB);
    MF.insert(MBBIter,ReserveMBB);
    MF.insert(MBBIter,ContinueMBB);


    //Split MBB and move the tail portion down to ContinueMBB
//    MachineBasicBlock::iterator BeforeMBBI = std::prev(MBI);
    ContinueMBB->splice(ContinueMBB->begin(),&MBB,MBI,MBB.end());
    ContinueMBB->transferSuccessorsAndUpdatePHIs(&MBB);

    //MBB
//    BuildMI(&MBB,DL,TII->get(X86::MOV64rr),X86::R14).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
//    BuildMI(&MBB,DL,TII->get(X86::SHL64ri), X86::R14).addReg(X86::R14).addImm(4).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
            .addReg(X86::R13).addImm(60).setMIFlag(MachineInstr::FrameSetup);

    //in fact, we may need more stack size than the newStackSize to store
    // return address ,stack perserved params etc.s  newStackSize = virtualRET+ trueRET + vritualrsp + extraCall + stacksize
    //TODO extra space for the leafFunc
    BuildMI(&MBB,DL,TII->get(X86::CMP16ri)).addReg(X86::R14W).addImm((newStackSize+8+8+8)<<4).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(&MBB,DL,TII->get(X86::JAE_1)).addMBB(ReserveMBB).setMIFlag(MachineInstr::FrameSetup);

    //AlignMBB
    BuildMI(AlignMBB,DL,TII->get(X86::SHR64ri),X86::R14).addReg(X86::R14).addImm(15).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
            .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(-16).addReg(0).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::SHL64ri),X86::R14).addReg(X86::R14).addImm(11).setMIFlag(MachineInstr::FrameSetup);

//    int total = 0;
    int maxCopyOffset = 0;

    if(StackValueNeedMov.size()){
        for(auto itr:StackValueNeedMov){
            int tmp = itr.first - 8*3 - stackSize;
            tmp = itr.second == 2? tmp+8:tmp;
            if(tmp > maxCopyOffset){
                maxCopyOffset = tmp;
            }

        }
        maxCopyOffset = (maxCopyOffset/16)*16 + 8;
        for(auto itr:StackValueNeedMov) {
            int offsetFromSP = itr.first - 8*3 -stackSize + 8;
            if(itr.second == 2) {

                BuildMI(AlignMBB, DL, TII->get(X86::LD_F80m))
                        .addReg(X86::RSP).addImm(1).addReg(0).addImm(offsetFromSP).addReg(0).setMIFlag(
                        MachineInstr::FrameSetup);
                BuildMI(AlignMBB, DL, TII->get(X86::ST_FP80m))
                        .addReg(X86::R14).addImm(1).addReg(0).addImm(offsetFromSP-maxCopyOffset-16).addReg(0).setMIFlag(
                        MachineInstr::FrameSetup);
            } else{

                BuildMI(AlignMBB, DL, TII->get(X86::LD_F64m))
                        .addReg(X86::RSP).addImm(1).addReg(0).addImm(offsetFromSP).addReg(0).setMIFlag(
                        MachineInstr::FrameSetup);
                BuildMI(AlignMBB, DL, TII->get(X86::ST_FP64m))
                        .addReg(X86::R14).addImm(1).addReg(0).addImm(offsetFromSP-maxCopyOffset-16).addReg(0).setMIFlag(
                        MachineInstr::FrameSetup);
            }
        }
        maxCopyOffset +=8;
    }

    if(stackSizeAll + 8 > 4096){
        errs()<<stackSizeAll+8<<" This function frame size is bigger than 4096.\n";
        //if the stack size is larger than a page, we need to register it in our loader structer.
        //here we assume the size is no more than 4096*3
//        BuildMI(&MBB,DL,TII->get(X86::MOV64ri),X86::R14)
//                .addExternalSymbol("_stack_over_register").setMIFlag(MachineInstr::FrameSetup);

        BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
                .addReg(X86::R14)
                .addImm(12).setMIFlag(MachineInstr::FrameSetup);
        BuildMI(&MBB,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameSetup);
        BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
                .addReg(X86::R14)
                .addImm(52).setMIFlag(MachineInstr::FrameSetup);
        BuildMI(AlignMBB,DL,TII->get(X86::CALL64r)).addReg(X86::R14).setMIFlag(MachineInstr::FrameSetup);

    }


    BuildMI(AlignMBB,DL,TII->get(X86::LEA64r),X86::RSP)
            .addReg(X86::R14).addImm(1).addReg(0).addImm(-maxCopyOffset).addReg(0).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::PUSH64r)).addReg(X86::RSP).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::PUSH64r)).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::PUSH64r)).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(AlignMBB,DL,TII->get(X86::AND64rm),X86::R13).addReg(X86::R13)
            .addReg(X86::R15).addImm(1).addReg(0).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameSetup);
            
    BuildMI(AlignMBB,DL,TII->get(X86::SUB64ri32),X86::R13).addReg(X86::R13)
            .addImm(newStackSize+8+8+maxCopyOffset).setMIFlag(MachineInstr::FrameSetup);


    BuildMI(AlignMBB,DL,TII->get(X86::JMP_1)).addMBB(ContinueMBB).setMIFlag(MachineInstr::FrameSetup);
    //ReserveMBB
    BuildMI(ReserveMBB,DL,TII->get(X86::PUSH64r)).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(ReserveMBB,DL,TII->get(X86::PUSH64r)).addReg(X86::R13).setMIFlag(MachineInstr::FrameSetup);
    BuildMI(ReserveMBB,DL,TII->get(X86::SUB64ri32),X86::R13).addReg(X86::R13)
            .addImm(newStackSize+8+8).setMIFlag(MachineInstr::FrameSetup);


    //ContinueMBB
//    MachineBasicBlock::iterator ContinueMBBI = ContinueMBB->getFirstNonPHI();

    //Add the control flow edges we need
    MBB.addSuccessor(ReserveMBB);
    MBB.addSuccessor(AlignMBB);
    AlignMBB->addSuccessor(ContinueMBB);
    ReserveMBB->addSuccessor(ContinueMBB);

#if PanDebug
    bool thereSubSP = false;

    MachineBasicBlock::iterator  temp;
    MachineBasicBlock::iterator  B=ContinueMBB->begin(),E=ContinueMBB->end();
    temp = B;
    for(;B!=E;B++){
        if(isSUB(B->getOpcode())){
            if(B->getOperand(0).isReg() && B->getOperand(0).getReg()==X86::RSP){
                temp = std::next(B);
                thereSubSP = true;
                continue;
            }
        } else if(isPOP(B->getOpcode())){
            temp = std::next(B);
            continue;
        }
    }

    MachineBasicBlock *CheckMBB= MF.CreateMachineBasicBlock(LLVM_BB);
    MachineBasicBlock *RemainMBB= MF.CreateMachineBasicBlock(LLVM_BB);
    MachineFunction::iterator ContinueMBBIter = std::next(ContinueMBB->getIterator());

    MF.insert(ContinueMBBIter,CheckMBB);
    MF.insert(ContinueMBBIter,RemainMBB);

    RemainMBB->splice(RemainMBB->begin(),ContinueMBB,temp,ContinueMBB->end());
    RemainMBB->transferSuccessorsAndUpdatePHIs(ContinueMBB);
    if(thereSubSP){
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::MOV64rr),X86::R14).addReg(X86::RBP);
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::SUB64rr),X86::R14).addReg(X86::R14).addReg(X86::RSP);
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::AND64ri32),X86::R14).addReg(X86::R14).addImm(0xfff);
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::TEST64ri32),X86::R14).addImm(0);
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::JE_1)).addMBB(RemainMBB);
        BuildMI(CheckMBB,temp->getDebugLoc(),TII->get(X86::JMP64m)).addReg(X86::R15).addImm(1).addReg(0).addImm(8).addReg(0);
    }
    ContinueMBB->addSuccessor(CheckMBB);
    CheckMBB->addSuccessor(RemainMBB);
#endif

    return true;
}
bool InsertEANDPrologue::handlePrologue(MachineFunction::iterator MFI,MachineBasicBlock::iterator proEnd) {
    MachineBasicBlock::iterator MBBI = MFI->begin();

    return alignStack(*MFI,MBBI,proEnd);

}
bool InsertEANDPrologue::handleBlock(MachineFunction::iterator MFI) {
    bool ismodified=false;
    MachineBasicBlock::iterator MBBI = MFI->begin(),MBE = MFI->end(),MBBI_temp;

    for(;MBBI!=MBE;){
        MBBI_temp=MBBI;
        MBBI++;
       ismodified |= handleInstruction(*MFI,MBBI_temp);
    }

    return ismodified;
}

bool InsertEANDPrologue::epalignStack(MachineBasicBlock &MBB) {
//    MachineFunction &MF=*MBB.getParent();
//    const Function *F = MF.getFunction();
    MachineBasicBlock::iterator MBBI = MBB.getFirstTerminator();
    const DebugLoc &DL = MBBI->getDebugLoc();


//    const int stackSizeAll = MF.getFrameInfo().getStackSize();

#if isStackPageAlign
//    int realDestroyStackSize=0;
//    for(MachineBasicBlock::iterator MBBI=MBB.begin(),MBBE=MBB.end();MBBI!=MBBE;MBBI++){
//        int opcode = MBBI->getOpcode();
//
//        if(!MBBI->getFlag(MachineInstr::FrameDestroy)) continue;
//
//        if(isPOP(opcode)){
//            realDestroyStackSize +=8;
//        } else if(isADD(opcode) && MBBI->getOperand(0).isReg() && MBBI->getOperand(0).getReg()==X86::RSP){
//            realDestroyStackSize +=MBBI->getOperand(2).getImm();
//        }
//    }
//
//    int stackSize = realDestroyStackSize;
//    int newStackSize = stackSize + 8;
//#if SGXBASIC
//    if(stackSizeAll == 0 || leafMachineFunctionSets[F]){
//        if(isTailJMP(MBBI->getOpcode())){
//            BuildMI(MBB,MBBI,DL,TII->get(X86::ADD64ri32),X86::R13).addReg(X86::R13).addImm(8).setMIFlag(MachineInstr::FrameDestroy);
//            return true;
//        }
//        if(isRET(MBBI->getOpcode())){
//            BuildMI(&MBB,DL,TII->get(X86::ADD64ri32),X86::R13).addReg(X86::R13).addImm(8+realDestroyStackSize).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::POP64r)).addReg(X86::R14).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
//                    .addReg(X86::R14)
//                    .addImm(11).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                    .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
//                    .addReg(X86::R14)
//                    .addImm(53).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::JMP64r))
//                    .addReg(X86::R14);
//                MBB.erase(MBBI);
//            return true;
//        }
//    }
//#endif //SGXBASIC
////    if(leafMachineFunctionSets[F]){
////        BuildMI(MBB,MBBI,DL,TII->get(X86::ADD64ri32),X86::R13).addReg(X86::R13).addImm(8+stackSize).setMIFlag(MachineInstr::FrameDestroy);
////        return true;
////    }
//
//    if (newStackSize >4086) {
//        errs()<<"this stack over 4096";
//    }
////    if(stackSize ==0)
////        return false;
//
//    // Skip the callee-saved pop instructions.
//    MachineBasicBlock::iterator FirstCSPop = MBBI;
//    int poptimes=0;
//    while (MBBI != MBB.begin()) {
//        MachineBasicBlock::iterator PI = std::prev(MBBI);
//        unsigned Opc = PI->getOpcode();
//
//        if (Opc != X86::DBG_VALUE && !PI->isTerminator()) {
//            if ((Opc != X86::POP32r || !PI->getFlag(MachineInstr::FrameDestroy)) &&
//                (Opc != X86::POP64r || !PI->getFlag(MachineInstr::FrameDestroy)))
//                break;
//            FirstCSPop = PI;
//            poptimes++;
//        }
//        --MBBI;
//    }
//    if(FirstCSPop!=MBB.begin()){
//        MBBI=std::prev(FirstCSPop);
//    } else{
//        MBBI=FirstCSPop;
//    }
//    //delete add operations of rsp
//    if(isADD(MBBI->getOpcode())
//       && MBBI->getOperand(0).isReg()
//       && MBBI->getOperand(0).getReg()==X86::RSP){
//        MBB.erase(MBBI);
//    } else{
////        MBBI->print(errs());
////        errs()<<"================== there is add rsp\n";
//    }
//
//    for(int i=0;i<poptimes;i++){
//        if(isPOP(FirstCSPop->getOpcode())){
//            unsigned savedRegister=FirstCSPop->getOperand(0).getReg();
//            MachineBasicBlock::iterator insertPoint = std::next(FirstCSPop);
//            BuildMI(MBB,FirstCSPop,FirstCSPop->getDebugLoc(),TII->get(X86::MOV64rm),savedRegister)
//                    .addReg(X86::RSP).addImm(1).addReg(0).addImm(stackSize - (poptimes-i)*8).addReg(0);
//            MBBI=FirstCSPop++;
//            MBB.erase(MBBI);
//        }
//    }
//
//  if(leafMachineFunctionSets[F]){
//      BuildMI(MBB,FirstCSPop,DL,TII->get(X86::ADD64ri32),X86::RSP).addReg(X86::RSP).addImm(24+stackSize).setMIFlag(MachineInstr::FrameDestroy);
//      //BuildMI(MBB,FirstCSPop,DL,TII->get(X86::ADD64ri32),X86::RSP).addReg(X86::RSP).addImm(24+stackSize).setMIFlag(MachineInstr::FrameDestroy);
//
//      BuildMI(MBB,FirstCSPop,DL,TII->get(X86::MOV64rm),X86::R14)
//              .addReg(X86::RSP).addImm(1).addReg(0).addImm(-16).addReg(0);
//
//      BuildMI(MBB,FirstCSPop,DL,TII->get(X86::ADD64ri32),X86::R13).addReg(X86::R13).addImm(24+stackSize).setMIFlag(MachineInstr::FrameDestroy);
//      BuildMI(MBB,FirstCSPop,DL,TII->get(X86::JMP64r))
//              .addReg(X86::R14);
//      MBB.erase(FirstCSPop);
//
//      return true;
//  }
//
//    if(isRET(FirstCSPop->getOpcode())){
//        MBB.erase(FirstCSPop);
//        // MBB:
//        // MOV [RSP + stackSize] RBP
//        // RORX RBP 12 R14
//        // ADD (R15 + R14D*8) RSP
//        // RORX R14 52 RSP
//        // RORX (RSP-8) 12 R14
//        // ADD  (R15 + R14D*8) R14
//        // RORX R14 52 R14
//        // jmp R14
//
//        BuildMI(&MBB,DL,TII->get(X86::MOV64rm),X86::R13)
//                .addReg(X86::RSP).addImm(1).addReg(0).addImm(stackSize).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
//                .addReg(X86::R13) .addImm(11).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::RSP)
//                .addReg(X86::R14)
//                .addImm(53).setMIFlag(MachineInstr::FrameDestroy);
//
//        if(MBB.getParent()->getName().startswith("enclave_main")){
//            BuildMI(&MBB,DL,TII->get(X86::POP64r),X86::R14).setMIFlag(MachineInstr::FrameDestroy);
//            BuildMI(&MBB,DL,TII->get(X86::JMP64r))
//                    .addReg(X86::R14);
//            return true;
//        }
//
//        BuildMI(&MBB,DL,TII->get(X86::RORX64mi),X86::R14)
//                .addReg(X86::RSP).addImm(1).addReg(0).addImm(-8).addReg(0)
//                .addImm(11).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::RORX64ri),X86::R14)
//                .addReg(X86::R14)
//                .addImm(53).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(&MBB,DL,TII->get(X86::JMP64r))
//                .addReg(X86::R14);
//
//    } else {
//
//        errs()<<"TailJMP :"<<MBB.getParent()->getName()<<"\n";
//        BuildMI(MBB,FirstCSPop,DL,TII->get(X86::MOV64rm),X86::R13)
//                .addReg(X86::RSP).addImm(1).addReg(0).addImm(stackSize+8).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//
//        BuildMI(MBB,FirstCSPop,DL,TII->get(X86::RORX64ri),X86::R14)
//                .addReg(X86::R13) .addImm(11).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(MBB,FirstCSPop,DL,TII->get(X86::ADD64rm),X86::R14).addReg(X86::R14)
//                .addReg(X86::R15D).addImm(8).addReg(X86::R14D).addImm(0).addReg(0).setMIFlag(MachineInstr::FrameDestroy);
//        BuildMI(MBB,FirstCSPop,DL,TII->get(X86::RORX64ri),X86::RSP)
//                .addReg(X86::R14)
//                .addImm(53).setMIFlag(MachineInstr::FrameDestroy);
//        if(isTailJMP(FirstCSPop->getOpcode())){
//            BuildMI(MBB,FirstCSPop,DL,TII->get(X86::SUB64ri32),X86::RSP).addReg(X86::RSP)
//                .addImm(8).setMIFlag(MachineInstr::FrameDestroy);
//        } else{
//            FirstCSPop->print(errs());errs()<<"Tail else\n";
//        }
//
//    }
#else
//    errs()<<"==================== check\n";
    unsigned opcode=MBBI->getOpcode();
    if(isRET(opcode)){
        // MBB:
        // pop $r14
        // jmp 0x40(%%r15)
        MBB.erase(MBBI);
        BuildMI(&MBB,DL,TII->get(X86::POP64r),X86::R14).setMIFlag(MachineInstr::FrameDestroy);
        BuildMI(&MBB,DL,TII->get(X86::TAILJMPm64))
                .addReg(X86::R15).addImm(1).addReg(0).addImm(0x40).addReg(0).setMIFlag(MachineInstr::FrameDestroy);

    } else if(isTailJMP(opcode)){
//        errs()<<"TailJMP :"<<MBB.getParent()->getName()<<"\n";
    } else{
        errs()<<"terminator instruction is not ret or tailjmp "<<__func__<<"\n";
        MBBI->print(errs());
        errs()<<"\n";
        exit(-1);
    }


#endif //isStackPageAlign

    return true;
}
bool InsertEANDPrologue::handleEPrologue(MachineBasicBlock &MBB) {

    epalignStack(MBB);

    return true;
}

bool InsertEANDPrologue::runOnMachineFunction(MachineFunction &MF){
    MachineFunction::iterator MFI, MFB=MF.begin(), MFE=MF.end();
    TII = MF.getSubtarget().getInstrInfo();
    TRI = MF.getSubtarget().getRegisterInfo();
//    MachineFrameInfo &MFFI = MF.getFrameInfo();
//    X86MachineFunctionInfo *X86FI = MF.getInfo<X86MachineFunctionInfo>();
//    MachineModuleInfo &MMI = getAnalysis<MachineModuleInfo>();
//    MachineBasicBlock::iterator PrologueEndInst = MFB->begin();
    std::unordered_map<MachineBasicBlock*,MachineInstr*> terminalBBset;
    SmallVector<MachineBasicBlock::iterator,2> popAndpushInstrExistInFunctionBody;
    SmallVector<MachineBasicBlock::iterator,2> subORaddRSPInFunctionBody;


//    const Function *function = MF.getFunction();
    if(MF.getName()=="fillPagetable")
        return false;
    if(MF.getName()=="main"){
        return true;
    }

    SmallVector<MachineBasicBlock *,4> terminalBBs;
    for(MFI=MF.begin();MFI!=MFE;++MFI){
        for(MachineBasicBlock::iterator MBBI=MFI->begin(),MBEI=MFI->end();MBBI!=MBEI;++MBBI){
            if(MBBI->isTerminator()){
                int opcode = MBBI->getOpcode();
                if(isRET(opcode)||isTailJMP(opcode)){
                    if(std::find(terminalBBs.begin(),terminalBBs.end(),&*MFI) == terminalBBs.end()){
                        terminalBBs.push_back(&*MFI);
                    }
                }
            }
        }
    }

#if isStackPageAlign
    int size=0;
    for(MFI=MF.begin();MFI!=MFE;++MFI){
        bool inEntry = MFI==MF.begin();
        bool inExitBlock = false;
        if(std::find(terminalBBs.begin(),terminalBBs.end(),&*MFI)!=terminalBBs.end()){
            inExitBlock = true;
        }
        for(MachineBasicBlock::iterator MBBI=MFI->begin(),MBEI=MFI->end();MBBI!=MBEI;++MBBI){
            MachineBasicBlock::iterator nextMBBI=std::next(MBBI);
            if(isPush(MBBI->getOpcode())){
                if(inEntry && MBBI->getFlag(MachineInstr::FrameSetup)) continue;
                size+=8;
                //if the next instruction is till push, continue
                if(nextMBBI!=MBEI && isPush(nextMBBI->getOpcode())){
                    continue;
                } else{
                    BuildMI(*MBBI->getParent(),MBBI,MBBI->getDebugLoc(),TII->get(X86::SUB64ri32),X86::R13)
                            .addReg(X86::R13).addImm(size);
                    size=0;
                }
            } else if(isPOP(MBBI->getOpcode())){
                if(inExitBlock && MBBI->getFlag(MachineInstr::FrameDestroy)) continue;
                size+=8;
                if(nextMBBI!=MBEI && isPOP(nextMBBI->getOpcode())){
                    continue;
                } else{
                    BuildMI(*MBBI->getParent(),MBBI,MBBI->getDebugLoc(),TII->get(X86::ADD64ri32),X86::R13)
                            .addReg(X86::R13).addImm(size);
                    size=0;
                }
            } else if(isADD(MBBI->getOpcode())
                      &&MBBI->getOperand(0).isReg() && MBBI->getOperand(0).getReg()==X86::RSP
                      &&!MBBI->mayLoadOrStore()){
                if(inExitBlock && MBBI->getFlag(MachineInstr::FrameDestroy)) continue;
                int val = MBBI->getOperand(2).getImm();
                BuildMI(*MBBI->getParent(),MBBI,MBBI->getDebugLoc(),TII->get(X86::ADD64ri32),X86::R13)
                        .addReg(X86::R13).addImm(val);
            } else if(isSUB(MBBI->getOpcode())
                      &&MBBI->getOperand(0).isReg() && MBBI->getOperand(0).getReg()==X86::RSP
                      &&!MBBI->mayLoadOrStore()){
                if(inEntry && MBBI->getFlag(MachineInstr::FrameSetup)) continue;
                int val = MBBI->getOperand(2).getImm();
                BuildMI(*MBBI->getParent(),MBBI,MBBI->getDebugLoc(),TII->get(X86::SUB64ri32),X86::R13)
                        .addReg(X86::R13).addImm(val);
            }
        }
    }

    //for the stack hole is
//    if(MF.getFrameInfo().getStackSize() == 0 || leafMachineFunctionSets[function]){
//        for(MFI=MF.begin();MFI!=MFE;++MFI){
//            for(MachineBasicBlock::iterator MBBI=MFI->begin(),MBEI=MFI->end();MBBI!=MBEI;++MBBI){
//                if(MBBI->mayLoadOrStore() && !isPOPorPush(MBBI->getOpcode())){
//                    int baseIndex = findMemOprandFirstIndex(*MBBI);
//                    if(baseIndex<0){
//                        continue;
//                    }
//                    MachineOperand &base = MBBI->getOperand(baseIndex);
//                    if(base.isReg() && base.getReg()==X86::RSP){
//                        int64_t stackOffset = MBBI->getOperand(baseIndex+3).getImm();
//                        if(stackOffset > MF.getFrameInfo().getStackSize()){
//                            stackOffset -= 16;
//                            MBBI->getOperand(baseIndex+3).setImm(stackOffset);
//                        }
//                    }
//                }
//            }
//        }
//
//    }

    //errs()<<"Function Name:  "<<MF.getName()<<" "<<MF.getFrameInfo().getStackSize()<<" "<<X86FI->getCalleeSavedFrameSize()<<"\n";

    uint64_t stackSize = MF.getFrameInfo().getStackSize();

    for(MFI=MF.begin();MFI!=MFE;++MFI){
        for(MachineBasicBlock::iterator MBBI=MFI->begin(),MBEI=MFI->end();MBBI!=MBEI;++MBBI){
            int opcode = MBBI->getOpcode();
            if(MBBI->getFlag(MachineInstr::FrameSetup)){
                //handle prologue
                if(isPush(opcode)||isSUB(opcode)){
                    PrologueEndInst = MBBI;
                }
            }else{
                if((isPush(opcode)||isPOP(opcode)) && !MBBI->getFlag(MachineInstr::FrameDestroy)){
                    popAndpushInstrExistInFunctionBody.push_back(MBBI);
                }
                if((isADD(opcode)||isSUB(opcode))
                                  &&MBBI->getOperand(0).isReg() && MBBI->getOperand(0).getReg()==X86::RSP
                                  &&!MBBI->mayLoadOrStore()
                                  &&!MBBI->getFlag(MachineInstr::FrameDestroy))
                    subORaddRSPInFunctionBody.push_back(MBBI);
            }

            if(MBBI->mayLoadOrStore()){
                if(!isPOPorPush(opcode) && !MBBI->isInlineAsm()){
                    int base=findMemOprandFirstIndex(*MBBI);
                    if(MBBI->getOperand(base).isReg() && MBBI->getOperand(base).getReg() == X86::RSP){
                        int frameIndex = MBBI->getOperand(base+3).getImm();
                        if(frameIndex>stackSize){
                            MBBI->print(errs());
                            if(isLD_F80m(opcode)){
                                StackValueNeedMov[frameIndex]= 2;
                            } else{
                                StackValueNeedMov[frameIndex]= 1;
                            }
                        }
                    }
                }
            }
        }
    }

    handlePrologue(MFB,PrologueEndInst);
#endif //isStackPageAlign

    for(MFI=MF.begin();MFI!=MFE;++MFI){
        for(MachineBasicBlock::iterator MBBI=MFI->begin(),MBEI=MFI->end();MBBI!=MBEI;++MBBI){
            if(MBBI->isTerminator()){
                int opcode = MBBI->getOpcode();
                if(isRET(opcode)||isTailJMP(opcode)){
                    auto itr = terminalBBset.find(&*MFI);
                    if(itr == terminalBBset.end()){
                        terminalBBset[MBBI->getParent()]=&*MBBI;
                    }
                }
            }
        }
    }

    //printPOPandPUSH()
    for(auto itr: terminalBBset){
        handleEPrologue(*itr.first);
    }
    StackValueNeedMov.clear();
    return false;
}

FunctionPass *llvm::insertEandPrologue(){
    return new InsertEANDPrologue();
}

//static RegisterPass<InsertEANDPrologue> X("insertEandPrologue", "insert Prologue and Eprologue before and after each function");