//===- MCObjectStreamer.h - MCStreamer Object File Interface ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCOBJECTSTREAMER_H
#define LLVM_MC_MCOBJECTSTREAMER_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCStreamer.h"

namespace llvm {
class MCAssembler;
class MCCodeEmitter;
class MCSubtargetInfo;
class MCExpr;
class MCFragment;
class MCDataFragment;
class MCAsmBackend;
class raw_ostream;
class raw_pwrite_stream;

#define  Pan_Page_Align 11
/// \brief Streaming object file generation interface.
///
/// This class provides an implementation of the MCStreamer interface which is
/// suitable for use with the assembler backend. Specific object file formats
/// are expected to subclass this interface to implement directives specific
/// to that file format or custom semantics expected by the object writer
/// implementation.
class MCObjectStreamer : public MCStreamer {
  MCAssembler *Assembler;
  MCSection::iterator CurInsertionPoint;
  MCSection::page_iterator CurInsertionPagePoint;
  MCSymbol *PendingMBBStartSymbol= nullptr;
  int CPISymbolIndex=0;
  bool EmitEHFrame;
  bool EmitDebugFrame;
  SmallVector<MCSymbol *, 2> PendingLabels;
  int MCBBStartFragmentTotalNum=1;
    int MCBBEndFragmentTotalNum=1;

  virtual void EmitInstToData(const MCInst &Inst, const MCSubtargetInfo&) = 0;
  virtual void EmitInstToRepalce(const MCInst &Inst, const MCSubtargetInfo &STI, const MCReplaceableFragment &,SmallString<256> &){};
  void EmitCFIStartProcImpl(MCDwarfFrameInfo &Frame) override;
  void EmitCFIEndProcImpl(MCDwarfFrameInfo &Frame) override;

protected:
  MCObjectStreamer(MCContext &Context, MCAsmBackend &TAB, raw_pwrite_stream &OS,
                   MCCodeEmitter *Emitter);
  ~MCObjectStreamer() override;

public:
  /// state management
  void reset() override;

  /// Object streamers require the integrated assembler.
  bool isIntegratedAssemblerRequired() const override { return true; }

  void EmitFrames(MCAsmBackend *MAB);
  void EmitCFISections(bool EH, bool Debug) override;

  MCFragment *getCurrentFragment() const;
  MCSection::iterator getCurrentFragmentIterate();
  MCFragment * getSectionCurrFragment(MCSection *MCS);
  MCSection::iterator getSectionCurrFragmentIterate(MCSection *MCS);
  MCPage *getCurrentPage()const;
  MCPage *getCurrentPage(MCSection *MCS)const;
  void insertNewPage(MCPage *page);

  virtual void setCurrentMFStatic(MCSection *MCS,MachineFunction *MF) override {
      getCFStatic().setCurrentMF(MF);
      getCFStatic().setCurrentPage(getCurrentPage(MCS));
      getCFStatic().setStartFragment(getSectionCurrFragment(MCS));
      getCFStatic().setStartFragmentIter(getSectionCurrFragmentIterate(MCS));
   }
    virtual void setStartFragmentStatic(){}
    virtual void setCurrentPageStatic(){}
    //return true if A new function generated
    virtual bool addFuncToPage(MCSection* MCS,MCSymbol* funcSymbol, int approxSize){
        //errs()<<"funcSymbol: "<<funcSymbol->getName()<<"\n";
        bool aNewPage = false;
        MCCodePage *page = cast<MCCodePage>(getCurrentPage(MCS));
        int remainSize = page->getRemainSize();
        //if there is enough size,add this func to the current page ,otherwise allocate a new page,and add to the section
        if(approxSize <=remainSize){
            page->addFunctionSymbol(funcSymbol);
            page->setRemainSize(remainSize-approxSize);
//            errs()<<"remain Size: to "<<funcSymbol->getName()<<" "<<page->getRemainSize()<<"\n";
            funcSymbol->setPage(page);
        } else{// add an alignfragment to the function and alloc a new page and set the currentPage = newpage
            //ToDo find a Page that remain enough space to hold the function.
//            errs()<<"---------------------- page index: "<<page->getPageIndex()<<"\n";
            for(MCCodePage::func_symbol_iterator B=page->funcSymbolBegin(),E=page->funcSymbolEnd(); B!=E;B++){
//                MCSymbol * symbol=*B;
//                errs()<<symbol->getName()<<"\n";
            }
//            errs()<<"----------------------page end;\n";
            if(getCurrentSectionOnly()->getKind().isText()){
                EmitPageAlign(std::next(getCFStatic().getStartFragmentIter()),page->getPageWide());
            }
            MCCodePage *newPage=new MCCodePage(page->getParent(),page->getPageIndex() + 1);
            newPage->addFunctionSymbol(funcSymbol);
            newPage->setRemainSize(newPage->getPageSize()-approxSize);
            funcSymbol->setPage(newPage);
            aNewPage=true;
        }
        page = cast<MCCodePage>(getCurrentPage(MCS));
        MCSection::iterator funFragment = getCFStatic().getStartFragmentIter();
        //errs()<<funcSymbol->getName()<<"\n";
        for(MCSection::iterator i= (++funFragment),e=MCS->end();i!=e;i++){
            i->setPageParent(page);
            //errs()<<i->getOrderInPage()<<"\n";
        }
        return aNewPage;
    }

    void insertPageAlignFragment(MCFragment *F,MCSection::iterator insertionPoint){
        MCSection *CurSection = getCurrentSectionOnly();
        CurSection->getFragmentList().insert(insertionPoint,F);
        F->setParent(CurSection);
    }

  void insert(MCFragment *F) {
    flushPendingLabels(F);
    MCSection *CurSection = getCurrentSectionOnly();
    CurSection->getFragmentList().insert(CurInsertionPoint, F);
    F->setParent(CurSection);
  }

  /// Get a data fragment to write into, creating a new one if the current
  /// fragment is not a data fragment.
  MCDataFragment *getOrCreateDataFragment();

protected:
  bool changeSectionImpl(MCSection *Section, const MCExpr *Subsection);

  /// If any labels have been emitted but not assigned fragments, ensure that
  /// they get assigned, either to F if possible or to a new data fragment.
  /// Optionally, it is also possible to provide an offset \p FOffset, which
  /// will be used as a symbol offset within the fragment.
  void flushPendingLabels(MCFragment *F, uint64_t FOffset = 0);

public:
  void visitUsedSymbol(const MCSymbol &Sym) override;

  MCAssembler &getAssembler() { return *Assembler; }

  /// \name MCStreamer Interface
  /// @{
  void EmitPageAlign(MCSection::iterator insertionPoint, unsigned pageWide);
  void EmitLabel(MCSymbol *Symbol, SMLoc Loc = SMLoc()) override;
  virtual void EmitLabel(MCSymbol *Symbol, SMLoc Loc, MCFragment *F);
  void EmitAssignment(MCSymbol *Symbol, const MCExpr *Value) override;
  void EmitValueImpl(const MCExpr *Value, unsigned Size,
                     SMLoc Loc = SMLoc()) override;
  void EmitULEB128Value(const MCExpr *Value) override;
  void EmitSLEB128Value(const MCExpr *Value) override;
  void EmitWeakReference(MCSymbol *Alias, const MCSymbol *Symbol) override;
  void ChangeSection(MCSection *Section, const MCExpr *Subsection) override;
  void EmitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                       bool = false) override;
  void EmitInstructionWithReplaceable(const MCInst *InstSrc, const MCInst * InstReplace_MOV, const MCInst * InstReplace_jp,const MCSymbol * targetBB, const MCSubtargetInfo &STI,
                                                bool PrintSchedInfo = false)override;
  void EmitConstantFragment(int CPI,int size, unsigned align, MCSymbol *symbol= nullptr,MCSymbol *Nsymbol= nullptr)override ;
  void EmitInstructionInPageJmp(const MCInst *InstSrc, const MCSubtargetInfo &STI,
                                                    bool PrintSchedInfo )override;
  /// \brief Emit an instruction to a special fragment, because this instruction
  /// can change its size during relaxation.
  virtual void EmitInstToFragment(const MCInst &Inst, const MCSubtargetInfo &);

  void EmitBundleAlignMode(unsigned AlignPow2) override;
  void EmitBundleLock(bool AlignToEnd) override;
  void EmitBundleUnlock() override;
  void EmitBytes(StringRef Data) override;
  void EmitValueToAlignment(unsigned ByteAlignment, int64_t Value = 0,
                            unsigned ValueSize = 1,
                            unsigned MaxBytesToEmit = 0) override;
  void EmitCodeAlignment(unsigned ByteAlignment,
                         unsigned MaxBytesToEmit = 0) override;
  void EmitMCBBstart(MCSymbol *MBB,bool) override;
  void EmitMCBBend(MCSymbol *MBB,MCSymbol * targetMBB = nullptr, MCSymbol *implicate= nullptr) override ;

  void emitValueToOffset(const MCExpr *Offset, unsigned char Value,
                         SMLoc Loc) override;
  void EmitDwarfLocDirective(unsigned FileNo, unsigned Line,
                             unsigned Column, unsigned Flags,
                             unsigned Isa, unsigned Discriminator,
                             StringRef FileName) override;
  void EmitDwarfAdvanceLineAddr(int64_t LineDelta, const MCSymbol *LastLabel,
                                const MCSymbol *Label,
                                unsigned PointerSize);
  void EmitDwarfAdvanceFrameAddr(const MCSymbol *LastLabel,
                                 const MCSymbol *Label);
  void EmitCVLocDirective(unsigned FunctionId, unsigned FileNo, unsigned Line,
                          unsigned Column, bool PrologueEnd, bool IsStmt,
                          StringRef FileName, SMLoc Loc) override;
  void EmitCVLinetableDirective(unsigned FunctionId, const MCSymbol *Begin,
                                const MCSymbol *End) override;
  void EmitCVInlineLinetableDirective(unsigned PrimaryFunctionId,
                                      unsigned SourceFileId,
                                      unsigned SourceLineNum,
                                      const MCSymbol *FnStartSym,
                                      const MCSymbol *FnEndSym) override;
  void EmitCVDefRangeDirective(
      ArrayRef<std::pair<const MCSymbol *, const MCSymbol *>> Ranges,
      StringRef FixedSizePortion) override;
  void EmitCVStringTableDirective() override;
  void EmitCVFileChecksumsDirective() override;
  void EmitDTPRel32Value(const MCExpr *Value) override;
  void EmitDTPRel64Value(const MCExpr *Value) override;
  void EmitTPRel32Value(const MCExpr *Value) override;
  void EmitTPRel64Value(const MCExpr *Value) override;
  void EmitGPRel32Value(const MCExpr *Value) override;
  void EmitGPRel64Value(const MCExpr *Value) override;
  bool EmitRelocDirective(const MCExpr &Offset, StringRef Name,
                          const MCExpr *Expr, SMLoc Loc) override;
  using MCStreamer::emitFill;
  void emitFill(uint64_t NumBytes, uint8_t FillValue) override;
  void emitFill(const MCExpr &NumBytes, uint64_t FillValue,
                SMLoc Loc = SMLoc()) override;
  void emitFill(const MCExpr &NumValues, int64_t Size, int64_t Expr,
                SMLoc Loc = SMLoc()) override;
  void EmitFileDirective(StringRef Filename) override;

  void FinishImpl() override;

  /// Emit the absolute difference between two symbols if possible.
  ///
  /// Emit the absolute difference between \c Hi and \c Lo, as long as we can
  /// compute it.  Currently, that requires that both symbols are in the same
  /// data fragment.  Otherwise, do nothing and return \c false.
  ///
  /// \pre Offset of \c Hi is greater than the offset \c Lo.
  void emitAbsoluteSymbolDiff(const MCSymbol *Hi, const MCSymbol *Lo,
                              unsigned Size) override;

  bool mayHaveInstructions(MCSection &Sec) const override;
};

} // end namespace llvm

#endif
