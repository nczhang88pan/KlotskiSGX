//===- lib/MC/MCAssembler.cpp - Assembler Backend Implementation ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/Twine.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCAsmLayout.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCCodeView.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCFragment.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/LEB128.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
#include <cstring>
#include <cassert>
#include <cstdint>
#include <tuple>
#include <utility>

using namespace llvm;

#define DEBUG_TYPE "assembler"

namespace {
namespace stats {

STATISTIC(EmittedFragments, "Number of emitted assembler fragments - total");
STATISTIC(EmittedRelaxableFragments,
          "Number of emitted assembler fragments - relaxable");
STATISTIC(EmittedDataFragments,
          "Number of emitted assembler fragments - data");
STATISTIC(EmittedCompactEncodedInstFragments,
          "Number of emitted assembler fragments - compact encoded inst");
STATISTIC(EmittedAlignFragments,
          "Number of emitted assembler fragments - align");
STATISTIC(EmittedFillFragments,
          "Number of emitted assembler fragments - fill");
STATISTIC(EmittedOrgFragments,
          "Number of emitted assembler fragments - org");
//STATISTIC(EmittedMBBStartFragments,
//              "Number of emitted MBBStart fragments - MBBstart");
//STATISTIC(EmittedMBBEndFragments,
//              "Number of emitted MBBEnd fragments - MBBend");
STATISTIC(evaluateFixup, "Number of evaluated fixups");
STATISTIC(FragmentLayouts, "Number of fragment layouts");
STATISTIC(ObjectBytes, "Number of emitted object file bytes");
STATISTIC(RelaxationSteps, "Number of assembler layout and relaxation steps");
STATISTIC(RelaxedInstructions, "Number of relaxed instructions");
//STATISTIC(MCAsmPages, "Number of generate Pages");

} // end namespace stats
} // end anonymous namespace

// FIXME FIXME FIXME: There are number of places in this file where we convert
// what is a 64-bit assembler value used for computation into a value in the
// object file, which may truncate it. We should detect that truncation where
// invalid and report errors back.

/* *** */

MCAssembler::MCAssembler(MCContext &Context, MCAsmBackend &Backend,
                         MCCodeEmitter &Emitter, MCObjectWriter &Writer)
    : Context(Context), Backend(Backend), Emitter(Emitter), Writer(Writer),
      BundleAlignSize(0), RelaxAll(false), SubsectionsViaSymbols(false),
      IncrementalLinkerCompatible(false), ELFHeaderEFlags(0) {
  VersionMinInfo.Major = 0; // Major version == 0 for "none specified"
}

MCAssembler::~MCAssembler() = default;

void MCAssembler::reset() {
  Sections.clear();
  Symbols.clear();
  IndirectSymbols.clear();
  DataRegions.clear();
  LinkerOptions.clear();
  FileNames.clear();
  ThumbFuncs.clear();
  BundleAlignSize = 0;
  RelaxAll = false;
  SubsectionsViaSymbols = false;
  IncrementalLinkerCompatible = false;
  ELFHeaderEFlags = 0;
  LOHContainer.reset();
  VersionMinInfo.Major = 0;
  for(MCAsmPage *page:MCAsmPageList){
      delete page;
  }
  MCAsmPageList.clear();

  // reset objects owned by us
  getBackend().reset();
  getEmitter().reset();
  getWriter().reset();
  getLOHContainer().reset();
}

bool MCAssembler::registerSection(MCSection &Section) {
  if (Section.isRegistered())
    return false;
  Sections.push_back(&Section);
  Section.setIsRegistered(true);
  return true;
}

bool MCAssembler::isThumbFunc(const MCSymbol *Symbol) const {
  if (ThumbFuncs.count(Symbol))
    return true;

  if (!Symbol->isVariable())
    return false;

  const MCExpr *Expr = Symbol->getVariableValue();

  MCValue V;
  if (!Expr->evaluateAsRelocatable(V, nullptr, nullptr))
    return false;

  if (V.getSymB() || V.getRefKind() != MCSymbolRefExpr::VK_None)
    return false;

  const MCSymbolRefExpr *Ref = V.getSymA();
  if (!Ref)
    return false;

  if (Ref->getKind() != MCSymbolRefExpr::VK_None)
    return false;

  const MCSymbol &Sym = Ref->getSymbol();
  if (!isThumbFunc(&Sym))
    return false;

  ThumbFuncs.insert(Symbol); // Cache it.
  return true;
}

bool MCAssembler::isSymbolLinkerVisible(const MCSymbol &Symbol) const {
  // Non-temporary labels should always be visible to the linker.
  if (!Symbol.isTemporary())
    return true;

  // Absolute temporary labels are never visible.
  if (!Symbol.isInSection())
    return false;

  if (Symbol.isUsedInReloc())
    return true;

  return false;
}

const MCSymbol *MCAssembler::getAtom(const MCSymbol &S) const {
  // Linker visible symbols define atoms.
  if (isSymbolLinkerVisible(S))
    return &S;

  // Absolute and undefined symbols have no defining atom.
  if (!S.isInSection())
    return nullptr;

  // Non-linker visible symbols in sections which can't be atomized have no
  // defining atom.
  if (!getContext().getAsmInfo()->isSectionAtomizableBySymbols(
          *S.getFragment()->getParent()))
    return nullptr;

  // Otherwise, return the atom for the containing fragment.
  return S.getFragment()->getAtom();
}

bool MCAssembler::evaluateFixup(const MCAsmLayout &Layout,
                                const MCFixup &Fixup, const MCFragment *DF,
                                MCValue &Target, uint64_t &Value) const {
  ++stats::evaluateFixup;

  // FIXME: This code has some duplication with recordRelocation. We should
  // probably merge the two into a single callback that tries to evaluate a
  // fixup and records a relocation if one is needed.
  const MCExpr *Expr = Fixup.getValue();
  if (!Expr->evaluateAsRelocatable(Target, &Layout, &Fixup)) {
    getContext().reportError(Fixup.getLoc(), "expected relocatable expression");
    // Claim to have completely evaluated the fixup, to prevent any further
    // processing from being done.
    Value = 0;
    return true;
  }

  bool IsPCRel = Backend.getFixupKindInfo(
    Fixup.getKind()).Flags & MCFixupKindInfo::FKF_IsPCRel;

  bool IsResolved;
  if (IsPCRel) {
    if (Target.getSymB()) {
      IsResolved = false;
    } else if (!Target.getSymA()) {
      IsResolved = false;
    } else {
      const MCSymbolRefExpr *A = Target.getSymA();
      const MCSymbol &SA = A->getSymbol();
      if (A->getKind() != MCSymbolRefExpr::VK_None || SA.isUndefined()) {
        IsResolved = false;
      } else {
        IsResolved = getWriter().isSymbolRefDifferenceFullyResolvedImpl(
            *this, SA, *DF, false, true);
      }
    }
  } else {
    IsResolved = Target.isAbsolute();
  }

  Value = Target.getConstant();

  if (const MCSymbolRefExpr *A = Target.getSymA()) {
    const MCSymbol &Sym = A->getSymbol();
    if (Sym.isDefined())
      Value += Layout.getSymbolOffset(Sym);
  }
  if (const MCSymbolRefExpr *B = Target.getSymB()) {
    const MCSymbol &Sym = B->getSymbol();
    if (Sym.isDefined())
      Value -= Layout.getSymbolOffset(Sym);
  }

  bool ShouldAlignPC = Backend.getFixupKindInfo(Fixup.getKind()).Flags &
                         MCFixupKindInfo::FKF_IsAlignedDownTo32Bits;
  assert((ShouldAlignPC ? IsPCRel : true) &&
    "FKF_IsAlignedDownTo32Bits is only allowed on PC-relative fixups!");

  if (IsPCRel) {
    uint32_t Offset = Layout.getFragmentOffset(DF) + Fixup.getOffset();

    // A number of ARM fixups in Thumb mode require that the effective PC
    // address be determined as the 32-bit aligned version of the actual offset.
    if (ShouldAlignPC) Offset &= ~0x3;
    Value -= Offset;
  }

  // Let the backend adjust the fixup value if necessary, including whether
  // we need a relocation.
  Backend.processFixupValue(*this, Layout, Fixup, DF, Target, Value,
                            IsResolved);

  return IsResolved;
}

uint64_t MCAssembler::computeFragmentSize(const MCAsmLayout &Layout,
                                          const MCFragment &F) const {
  switch (F.getKind()) {
  case MCFragment::FT_Data:
    return cast<MCDataFragment>(F).getContents().size();
  case MCFragment::FT_Relaxable:
    return cast<MCRelaxableFragment>(F).getContents().size();
  case MCFragment::FT_MBEnd:
          return cast<MCReplaceableFragment>(F).getContents().size();
  case MCFragment::FT_CompactEncodedInst:
    return cast<MCCompactEncodedInstFragment>(F).getContents().size();
  case MCFragment::FT_Fill:
    return cast<MCFillFragment>(F).getSize();

  case MCFragment::FT_LEB:
    return cast<MCLEBFragment>(F).getContents().size();

  case MCFragment::FT_SafeSEH:
    return 4;
  case MCFragment::FT_Constant:
    return cast<MCMBBConstantFragment>(F).getContents().size();
  case MCFragment::FT_MBBegin:
  case MCFragment::FT_Align: {
    const MCAlignFragment &AF = cast<MCAlignFragment>(F);
    unsigned Offset = Layout.getFragmentOffset(&AF);
    unsigned Size = OffsetToAlignment(Offset, AF.getAlignment());
    // If we are padding with nops, force the padding to be larger than the
    // minimum nop size.
    if (Size > 0 && AF.hasEmitNops()) {
      while (Size % getBackend().getMinimumNopSize())
        Size += AF.getAlignment();
    }
    if (Size > AF.getMaxBytesToEmit())
      return 0;
    return Size;
  }

  case MCFragment::FT_Org: {
    const MCOrgFragment &OF = cast<MCOrgFragment>(F);
    MCValue Value;
    if (!OF.getOffset().evaluateAsValue(Value, Layout)) {
      getContext().reportError(OF.getLoc(),
                               "expected assembly-time absolute expression");
        return 0;
    }

    uint64_t FragmentOffset = Layout.getFragmentOffset(&OF);
    int64_t TargetLocation = Value.getConstant();
    if (const MCSymbolRefExpr *A = Value.getSymA()) {
      uint64_t Val;
      if (!Layout.getSymbolOffset(A->getSymbol(), Val)) {
        getContext().reportError(OF.getLoc(), "expected absolute expression");
        return 0;
      }
      TargetLocation += Val;
    }
    int64_t Size = TargetLocation - FragmentOffset;
    if (Size < 0 || Size >= 0x40000000) {
      getContext().reportError(
          OF.getLoc(), "invalid .org offset '" + Twine(TargetLocation) +
                           "' (at offset '" + Twine(FragmentOffset) + "')");
      return 0;
    }
    return Size;
  }

  case MCFragment::FT_Dwarf:
    return cast<MCDwarfLineAddrFragment>(F).getContents().size();
  case MCFragment::FT_DwarfFrame:
    return cast<MCDwarfCallFrameFragment>(F).getContents().size();
  case MCFragment::FT_CVInlineLines:
    return cast<MCCVInlineLineTableFragment>(F).getContents().size();
  case MCFragment::FT_CVDefRange:
    return cast<MCCVDefRangeFragment>(F).getContents().size();
  case MCFragment::FT_Dummy:
    llvm_unreachable("Should not have been added");
  }

  llvm_unreachable("invalid fragment kind");
}

void MCAsmLayout::layoutFragment(MCFragment *F) {
  MCFragment *Prev = F->getPrevNode();

  // We should never try to recompute something which is valid.
  assert(!isFragmentValid(F) && "Attempt to recompute a valid fragment!");
  // We should never try to compute the fragment layout if its predecessor
  // isn't valid.
  assert((!Prev || isFragmentValid(Prev)) &&
         "Attempt to compute fragment before its predecessor!");

  ++stats::FragmentLayouts;

  // Compute fragment offset and size.
  if (Prev)
    F->Offset = Prev->Offset + getAssembler().computeFragmentSize(*this, *Prev);
  else
    F->Offset = 0;
  LastValidFragment[F->getParent()] = F;

  // If bundling is enabled and this fragment has instructions in it, it has to
  // obey the bundling restrictions. With padding, we'll have:
  //
  //
  //        BundlePadding
  //             |||
  // -------------------------------------
  //   Prev  |##########|       F        |
  // -------------------------------------
  //                    ^
  //                    |
  //                    F->Offset
  //
  // The fragment's offset will point to after the padding, and its computed
  // size won't include the padding.
  //
  // When the -mc-relax-all flag is used, we optimize bundling by writting the
  // padding directly into fragments when the instructions are emitted inside
  // the streamer. When the fragment is larger than the bundle size, we need to
  // ensure that it's bundle aligned. This means that if we end up with
  // multiple fragments, we must emit bundle padding between fragments.
  //
  // ".align N" is an example of a directive that introduces multiple
  // fragments. We could add a special case to handle ".align N" by emitting
  // within-fragment padding (which would produce less padding when N is less
  // than the bundle size), but for now we don't.
  //
  if (Assembler.isBundlingEnabled() && F->hasInstructions()) {
    assert(isa<MCEncodedFragment>(F) &&
           "Only MCEncodedFragment implementations have instructions");
    uint64_t FSize = Assembler.computeFragmentSize(*this, *F);

    if (!Assembler.getRelaxAll() && FSize > Assembler.getBundleAlignSize())
      report_fatal_error("Fragment can't be larger than a bundle size");

    uint64_t RequiredBundlePadding = computeBundlePadding(Assembler, F,
                                                          F->Offset, FSize);
    if (RequiredBundlePadding > UINT8_MAX)
      report_fatal_error("Padding cannot exceed 255 bytes");
    F->setBundlePadding(static_cast<uint8_t>(RequiredBundlePadding));
    F->Offset += RequiredBundlePadding;
  }
}

void MCAssembler::registerSymbol(const MCSymbol &Symbol, bool *Created) {
  bool New = !Symbol.isRegistered();
  if (Created)
    *Created = New;
  if (New) {
    Symbol.setIsRegistered(true);
    Symbols.push_back(&Symbol);
  }
}

void MCAssembler::writeFragmentPadding(const MCFragment &F, uint64_t FSize,
                                       MCObjectWriter *OW) const {
  // Should NOP padding be written out before this fragment?
  unsigned BundlePadding = F.getBundlePadding();
  if (BundlePadding > 0) {
    assert(isBundlingEnabled() &&
           "Writing bundle padding with disabled bundling");
    assert(F.hasInstructions() &&
           "Writing bundle padding for a fragment without instructions");

    unsigned TotalLength = BundlePadding + static_cast<unsigned>(FSize);
    if (F.alignToBundleEnd() && TotalLength > getBundleAlignSize()) {
      // If the padding itself crosses a bundle boundary, it must be emitted
      // in 2 pieces, since even nop instructions must not cross boundaries.
      //             v--------------v   <- BundleAlignSize
      //        v---------v             <- BundlePadding
      // ----------------------------
      // | Prev |####|####|    F    |
      // ----------------------------
      //        ^-------------------^   <- TotalLength
      unsigned DistanceToBoundary = TotalLength - getBundleAlignSize();
      if (!getBackend().writeNopData(DistanceToBoundary, OW))
          report_fatal_error("unable to write NOP sequence of " +
                             Twine(DistanceToBoundary) + " bytes");
      BundlePadding -= DistanceToBoundary;
    }
    if (!getBackend().writeNopData(BundlePadding, OW))
      report_fatal_error("unable to write NOP sequence of " +
                         Twine(BundlePadding) + " bytes");
  }
}

/// \brief Write the fragment \p F to the output file.
static void writeFragment(const MCAssembler &Asm, const MCAsmLayout &Layout,
                          const MCFragment &F) {
  MCObjectWriter *OW = &Asm.getWriter();

  // FIXME: Embed in fragments instead?
  uint64_t FragmentSize = Asm.computeFragmentSize(Layout, F);

  Asm.writeFragmentPadding(F, FragmentSize, OW);

  // This variable (and its dummy usage) is to participate in the assert at
  // the end of the function.
  uint64_t Start = OW->getStream().tell();
  (void) Start;

  ++stats::EmittedFragments;

  switch (F.getKind()) {
  case MCFragment::FT_MBBegin:
  case MCFragment::FT_Align: {
    ++stats::EmittedAlignFragments;
    const MCAlignFragment &AF = cast<MCAlignFragment>(F);
    assert(AF.getValueSize() && "Invalid virtual align in concrete fragment!");

    uint64_t Count = FragmentSize / AF.getValueSize();

    // FIXME: This error shouldn't actually occur (the front end should emit
    // multiple .align directives to enforce the semantics it wants), but is
    // severe enough that we want to report it. How to handle this?
    if (Count * AF.getValueSize() != FragmentSize)
      report_fatal_error("undefined .align directive, value size '" +
                        Twine(AF.getValueSize()) +
                        "' is not a divisor of padding size '" +
                        Twine(FragmentSize) + "'");

    // See if we are aligning with nops, and if so do that first to try to fill
    // the Count bytes.  Then if that did not fill any bytes or there are any
    // bytes left to fill use the Value and ValueSize to fill the rest.
    // If we are aligning with nops, ask that target to emit the right data.
    if (AF.hasEmitNops()) {
      if (!Asm.getBackend().writeNopData(Count, OW))
        report_fatal_error("unable to write nop sequence of " +
                          Twine(Count) + " bytes");
      break;
    }

    // Otherwise, write out in multiples of the value size.
    for (uint64_t i = 0; i != Count; ++i) {
      switch (AF.getValueSize()) {
      default: llvm_unreachable("Invalid size!");
      case 1: OW->write8 (uint8_t (AF.getValue())); break;
      case 2: OW->write16(uint16_t(AF.getValue())); break;
      case 4: OW->write32(uint32_t(AF.getValue())); break;
      case 8: OW->write64(uint64_t(AF.getValue())); break;
      }
    }
    break;
  }
  case MCFragment::FT_Constant:
    break;

  case MCFragment::FT_Data: 
    ++stats::EmittedDataFragments;
    OW->writeBytes(cast<MCDataFragment>(F).getContents());
    break;

  case MCFragment::FT_Relaxable:
    ++stats::EmittedRelaxableFragments;
    OW->writeBytes(cast<MCRelaxableFragment>(F).getContents());
    break;

  case MCFragment::FT_MBEnd:
    ++stats::EmittedRelaxableFragments;
//    errs()<<__func__<<" size: "<<cast<MCReplaceableFragment>(F).getContents().size()<<"\n";
    OW->writeBytes(cast<MCReplaceableFragment>(F).getContents());
    break;

  case MCFragment::FT_CompactEncodedInst:
    ++stats::EmittedCompactEncodedInstFragments;
    OW->writeBytes(cast<MCCompactEncodedInstFragment>(F).getContents());
    break;

  case MCFragment::FT_Fill: {
    ++stats::EmittedFillFragments;
    const MCFillFragment &FF = cast<MCFillFragment>(F);
    uint8_t V = FF.getValue();
    const unsigned MaxChunkSize = 16;
    char Data[MaxChunkSize];
    memcpy(Data, &V, 1);
    for (unsigned I = 1; I < MaxChunkSize; ++I)
      Data[I] = Data[0];

    uint64_t Size = FF.getSize();
    for (unsigned ChunkSize = MaxChunkSize; ChunkSize; ChunkSize /= 2) {
      StringRef Ref(Data, ChunkSize);
      for (uint64_t I = 0, E = Size / ChunkSize; I != E; ++I)
        OW->writeBytes(Ref);
      Size = Size % ChunkSize;
    }
    break;
  }

  case MCFragment::FT_LEB: {
    const MCLEBFragment &LF = cast<MCLEBFragment>(F);
    OW->writeBytes(LF.getContents());
    break;
  }

  case MCFragment::FT_SafeSEH: {
    const MCSafeSEHFragment &SF = cast<MCSafeSEHFragment>(F);
    OW->write32(SF.getSymbol()->getIndex());
    break;
  }

  case MCFragment::FT_Org: {
    ++stats::EmittedOrgFragments;
    const MCOrgFragment &OF = cast<MCOrgFragment>(F);

    for (uint64_t i = 0, e = FragmentSize; i != e; ++i)
      OW->write8(uint8_t(OF.getValue()));

    break;
  }

  case MCFragment::FT_Dwarf: {
    const MCDwarfLineAddrFragment &OF = cast<MCDwarfLineAddrFragment>(F);
    OW->writeBytes(OF.getContents());
    break;
  }
  case MCFragment::FT_DwarfFrame: {
    const MCDwarfCallFrameFragment &CF = cast<MCDwarfCallFrameFragment>(F);
    OW->writeBytes(CF.getContents());
    break;
  }
  case MCFragment::FT_CVInlineLines: {
    const auto &OF = cast<MCCVInlineLineTableFragment>(F);
    OW->writeBytes(OF.getContents());
    break;
  }
  case MCFragment::FT_CVDefRange: {
    const auto &DRF = cast<MCCVDefRangeFragment>(F);
    OW->writeBytes(DRF.getContents());
    break;
  }
  case MCFragment::FT_Dummy:
    llvm_unreachable("Should not have been added");
  }

  assert(OW->getStream().tell() - Start == FragmentSize &&
         "The stream should advance by fragment size");
}

void MCAssembler::writeSectionData(const MCSection *Sec,
                                   const MCAsmLayout &Layout) const {
    // if(Sec->getBeginSymbol()->getName().startswith(".bss") || Sec->getBeginSymbol()->getName().startswith(".data")){
    //     errs()<<Sec->getBeginSymbol()->getName()<<" we static here\n";
    //     for (MCSection::const_iterator I = Sec->begin(), IE = Sec->end(); I != IE; ++I) {
    //         int size = 0;
    //         switch(I->getKind()) {
    //             default:
    //                 break;
    //             case MCFragment::FT_Align: {
    //                 const MCAlignFragment *fragment = cast<MCAlignFragment>(I);
    //                 errs()<<"1FT_Align "<<fragment->getAlignment()<<"\n";
    //             }break;
    //             case MCFragment::FT_Data:{
    //                 const MCDataFragment *fragment = cast<MCDataFragment>(I);
    //                 errs()<<"2FT_Data: "<<fragment->getContents().size()<<"\n";
    //                 size = fragment->getContents().size();

    //             }
    //                 break;
    //             case MCFragment::FT_Fill:{
    //                 const MCFillFragment *fragment = cast<MCFillFragment>(I);
    //                 errs()<<"3FT_Fill: "<<fragment->getSize()<<"\n";
    //                 size=fragment->getSize();
    //             }
    //                 break;


    //         }
    //     }
    // }

  // Ignore virtual sections.
  if (Sec->isVirtualSection()) {
    assert(Layout.getSectionFileSize(Sec) == 0 && "Invalid size for section!");

    // Check that contents are only things legal inside a virtual section.
    for (const MCFragment &F : *Sec) {
      switch (F.getKind()) {
      default: llvm_unreachable("Invalid fragment in virtual section!");
      case MCFragment::FT_Data: {
        // Check that we aren't trying to write a non-zero contents (or fixups)
        // into a virtual section. This is to support clients which use standard
        // directives to fill the contents of virtual sections.
        const MCDataFragment &DF = cast<MCDataFragment>(F);
        if (DF.fixup_begin() != DF.fixup_end())
          report_fatal_error("cannot have fixups in virtual section!");
        for (unsigned i = 0, e = DF.getContents().size(); i != e; ++i)
          if (DF.getContents()[i]) {
            if (auto *ELFSec = dyn_cast<const MCSectionELF>(Sec))
              report_fatal_error("non-zero initializer found in section '" +
                  ELFSec->getSectionName() + "'");
            else
              report_fatal_error("non-zero initializer found in virtual section");
          }
        break;
      }
      case MCFragment::FT_Align:
        // Check that we aren't trying to write a non-zero value into a virtual
        // section.
        assert((cast<MCAlignFragment>(F).getValueSize() == 0 ||
                cast<MCAlignFragment>(F).getValue() == 0) &&
               "Invalid align in virtual section!");
        break;
      case MCFragment::FT_Fill:
        assert((cast<MCFillFragment>(F).getValue() == 0) &&
               "Invalid fill in virtual section!");
        break;
      }
    }

    return;
  }

  uint64_t Start = getWriter().getStream().tell();
  (void)Start;



  for (const MCFragment &F : *Sec)
    writeFragment(*this, Layout, F);

  assert(getWriter().getStream().tell() - Start ==
         Layout.getSectionAddressSize(Sec));
}

std::pair<uint64_t, bool> MCAssembler::handleFixup(const MCAsmLayout &Layout,
                                                   MCFragment &F,
                                                   const MCFixup &Fixup) {
  // Evaluate the fixup.
  MCValue Target;
  uint64_t FixedValue;
  bool IsPCRel = Backend.getFixupKindInfo(Fixup.getKind()).Flags &
                 MCFixupKindInfo::FKF_IsPCRel;
  if (!evaluateFixup(Layout, Fixup, &F, Target, FixedValue)) {
    // The fixup was unresolved, we need a relocation. Inform the object
    // writer of the relocation, and give it an opportunity to adjust the
    // fixup value if need be.
    getWriter().recordRelocation(*this, Layout, &F, Fixup, Target, IsPCRel,
                                 FixedValue);
  }
  return std::make_pair(FixedValue, IsPCRel);
}

void MCAssembler::alignDataSection(MCAsmLayout &Layout) {
    for (iterator it = begin(), ie = end(); it != ie; ++it) {
        MCSection &Sec = *it;
        if(Sec.getBeginSymbol()->getName().startswith(".bss") || Sec.getBeginSymbol()->getName().startswith(".data")){
            Sec.setAlignment(1<<Sec.getShadowPageWide());
            errs()<<".bss: =======\n";
            SmallVector<MCSection::iterator,4> insertSet;
//            bool isInserted=false;
            size_t currentOffset=0;
            insertSet.push_back(Sec.begin());
            for (MCSection::iterator I = Sec.begin(), IE = Sec.end(); I != IE; ++I) {
                int size = 0;
                switch(I->getKind()) {
                    default:
                        break;
                    case MCFragment::FT_Align: {
                        MCAlignFragment *fragment = cast<MCAlignFragment>(I);
//                        errs() << "current size:" << currentOffset << " FT_Align: " << fragment->getAlignment() << "\n";
                        size = OffsetToAlignment(currentOffset, fragment->getAlignment());
                        // If we are padding with nops, force the padding to be larger than the
                        // minimum nop size.
                        if (size > 0 && fragment->hasEmitNops()) {
                            while (size % getBackend().getMinimumNopSize())
                                size += fragment->getAlignment();
                        }
                    }
                        break;
                    case MCFragment::FT_Data: {
                        MCDataFragment *fragment = cast<MCDataFragment>(I);
//                        errs() << "FT_Data: " << fragment->getContents().size() << "\n";
                        size = fragment->getContents().size();
                    }
                        break;
                    case MCFragment::FT_Fill: {
                        MCFillFragment *fragment = cast<MCFillFragment>(I);
//                        errs() << "FT_Fill: " << fragment->getSize() << "\n";
                        size = fragment->getSize();
                    }
                }

                if(currentOffset+size>0x800){
                    if(size>0x800){
                        insertSet.push_back(I);
                        currentOffset=size;
                    }else if(I->getKind()==MCFragment::FT_Data || I->getKind()==MCFragment::FT_Fill){
                        currentOffset = 4;
                        if(std::prev(I)->getKind()==MCAlignFragment::FT_Align){
                            MCAlignFragment *fragment = cast<MCAlignFragment>(std::prev(I));
                            int tempsize = OffsetToAlignment(currentOffset, fragment->getAlignment());
                            if (tempsize > 0 && fragment->hasEmitNops()) {
                                while (tempsize % getBackend().getMinimumNopSize())
                                    tempsize += fragment->getAlignment();
                            }
                            currentOffset +=tempsize;

                        }
                        insertSet.push_back(I);
                        currentOffset+=size;
                    }
//                    else if(I->getKind()==MCFragment::FT_Align){
//
////                        insertSet.push_back(I);
//                        currentOffset = 0;
//                        MCAlignFragment *fragment = cast<MCAlignFragment>(I);
//                        errs()<<"eeeeeee======= "<< size<<"\n";
//                        static int timeit=0;
//                        size = OffsetToAlignment(currentOffset, fragment->getAlignment());
//                        if (size > 0 && fragment->hasEmitNops()) {
//                            while (size % getBackend().getMinimumNopSize())
//                                size += fragment->getAlignment();
//                        }
//                        currentOffset =size;
//                    }

                    errs()<<"current page over sized"<<currentOffset<<" "<<currentOffset+size<<"\n";
                } else{
                    currentOffset +=size;
                }
            }

            bool hasInserted=false;
            for(auto itr:insertSet){
                int size=0;
                MCAlignFragment *alignFragment = new MCAlignFragment(1<<11,0,1,1<<11);
                alignFragment->setParent(&Sec);

                bool prevIsAlign;
                if(itr==Sec.begin()){
                    prevIsAlign=false;
                }else{
                    prevIsAlign = (std::prev(itr)->getKind()==MCFragment::FT_Align);
                }

                if(prevIsAlign){
                    Sec.getFragmentList().insert(std::prev(itr),alignFragment);
                }else{
                    Sec.getFragmentList().insert(itr,alignFragment);
                }


                if(itr->getKind()==MCFragment::FT_Data){
                    size = cast<MCDataFragment>(itr)->getContents().size();
                } else if(itr->getKind()==MCFragment::FT_Fill){
                    size= cast<MCFillFragment>(itr)->getSize();
                }
                if((size<0x800) || (size>0x800 && !hasInserted)){
                    if(Sec.getBeginSymbol()->getName().startswith(".bss")){
                        MCFillFragment *mcFillFragment = new MCFillFragment(0,4);
                        mcFillFragment->setParent(&Sec);
                        if(prevIsAlign){
                            Sec.getFragmentList().insert(std::prev(itr),mcFillFragment);
                        }else{
                            Sec.getFragmentList().insert(itr,mcFillFragment);
                        }

                    }else if(Sec.getBeginSymbol()->getName().startswith(".data")){
                        MCDataFragment *dataFragment = new MCDataFragment();
                        dataFragment->setParent(&Sec);
                        char magicIndex[4]={0,0,(char)0x93,(char)0x93};
                        int typ=0x9020;
                        *(u_int32_t *)magicIndex = (u_int32_t )typ;
                        auto ORAMIndexString = StringRef(magicIndex,4);
                        dataFragment->getContents().append(ORAMIndexString.begin(),ORAMIndexString.end());

                        if(prevIsAlign){
                            Sec.getFragmentList().insert(std::prev(itr),dataFragment);
                        }else{
                            Sec.getFragmentList().insert(itr,dataFragment);
                        }
                    }

                    hasInserted=true;
                }

//               errs()<<StringRef(dataFragment->getContents().data(), dataFragment->getContents().size()).str()<<"  we want here\n";
            }

        }
    }
}

void MCAssembler::layout(MCAsmLayout &Layout) {
  DEBUG_WITH_TYPE("mc-dump", {
      errs() << "assembler backend - pre-layout\n--\n";
      dump(); });

  // Create dummy fragments and assign section ordinals.
  unsigned SectionIndex = 0;
  for (MCSection &Sec : *this) {
    // Create dummy fragments to eliminate any empty sections, this simplifies
    // layout.
    if (Sec.getFragmentList().empty())
      new MCDataFragment(&Sec);

    Sec.setOrdinal(SectionIndex++);
  }

  alignDataSection(Layout);

  // Assign layout order indices to sections and fragments.
  for (unsigned i = 0, e = Layout.getSectionOrder().size(); i != e; ++i) {
    MCSection *Sec = Layout.getSectionOrder()[i];
    Sec->setLayoutOrder(i);

    unsigned FragmentIndex = 0;
    for (MCFragment &Frag : *Sec)
      Frag.setLayoutOrder(FragmentIndex++);
  }

  // Layout until everything fits.
  while (layoutOnce(Layout))
    if (getContext().hadError())
      return;

    DEBUG_WITH_TYPE("mc-dump", {
      errs() << "assembler backend - post-relaxation\n--\n";
      dump(); });

  // Finalize the layout, including fragment lowering.
  finishLayout(Layout);

  DEBUG_WITH_TYPE("mc-dump", {
      errs() << "assembler backend - final-layout\n--\n";
      dump(); });

  // Allow the object writer a chance to perform post-layout binding (for
  // example, to set the index fields in the symbol data).
  getWriter().executePostLayoutBinding(*this, Layout);

  // Evaluate and apply the fixups, generating relocation entries as necessary.
  for (MCSection &Sec : *this) {
    for (MCFragment &Frag : Sec) {
      // Data and relaxable fragments both have fixups.  So only process
      // those here.
      // FIXME: Is there a better way to do this?  MCEncodedFragmentWithFixups
      // being templated makes this tricky.
//        if(Frag.getKind()==MCFragment::FT_MBEnd){
//            auto *FragWithFixups = dyn_cast<MCReplaceableFragment>(&Frag);
//        }
      if (isa<MCEncodedFragment>(&Frag) &&
          isa<MCCompactEncodedInstFragment>(&Frag))
        continue;
//        bool isaM=!isa<MCEncodedFragment>(&Frag);
//        bool isaC=!isa<MCCVDefRangeFragment>(&Frag);
        if (!isa<MCEncodedFragment>(&Frag) && !isa<MCCVDefRangeFragment>(&Frag))
        continue;
      ArrayRef<MCFixup> Fixups;
      MutableArrayRef<char> Contents;
      if (auto *FragWithFixups = dyn_cast<MCDataFragment>(&Frag)) {
        Fixups = FragWithFixups->getFixups();
        Contents = FragWithFixups->getContents();
      } else if (auto *FragWithFixups = dyn_cast<MCRelaxableFragment>(&Frag)) {
        Fixups = FragWithFixups->getFixups();
        Contents = FragWithFixups->getContents();
      } else if (auto *FragWithFixups = dyn_cast<MCCVDefRangeFragment>(&Frag)) {
        Fixups = FragWithFixups->getFixups();
        Contents = FragWithFixups->getContents();
      } else if(auto *FragWithFixups = dyn_cast<MCReplaceableFragment>(&Frag)){
          Fixups = FragWithFixups->getFixups();
          Contents = FragWithFixups->getContents();

//          errs()<<"FragWthiF:"<<FragWithFixups->getLayoutOrder()<<" "<<FragWithFixups->getTheAlternativeState()<<"\n";
//          FragWithFixups->getInst().print(errs());errs()<<"\n";

          for (const MCFixup &Fixup : Fixups) {
              uint64_t FixedValue;
              bool IsPCRel;
              std::tie(FixedValue, IsPCRel) = handleFixup(Layout, Frag, Fixup);
              getBackend().applyFixup(Fixup, Contents.data(), Contents.size(),
                                      FixedValue, IsPCRel, getContext());
          }
          continue;

      }else
        llvm_unreachable("Unknown fragment with fixups!");
      for (const MCFixup &Fixup : Fixups) {
        uint64_t FixedValue;
        bool IsPCRel;
        std::tie(FixedValue, IsPCRel) = handleFixup(Layout, Frag, Fixup);
        getBackend().applyFixup(Fixup, Contents.data(), Contents.size(),
                                FixedValue, IsPCRel, getContext());
      }
    }
  }
}

void MCAssembler::Finish() {
  // Create the layout object.
  MCAsmLayout Layout(*this);
  layout(Layout);

  raw_ostream &OS = getWriter().getStream();
  uint64_t StartOffset = OS.tell();

  // Write the object file.
  getWriter().writeObject(*this, Layout);

  stats::ObjectBytes += OS.tell() - StartOffset;
}

bool MCAssembler::fixupNeedsRelaxation(const MCFixup &Fixup, const MCReplaceableFragment *DF,
                                       const MCAsmLayout &Layout) const {
    MCValue Target;
    uint64_t Value;
 


    bool Resolved = evaluateFixup(Layout, Fixup, DF, Target, Value);
    if (Target.getSymA() &&
        Target.getSymA()->getKind() == MCSymbolRefExpr::VK_X86_ABS8 &&
        Fixup.getKind() == FK_Data_1)
        return false;
    if (!Resolved)
        return true;
    return int64_t(Value) != int64_t(int8_t(Value));
}

bool MCAssembler::fixupNeedsRelaxation(const MCFixup &Fixup,
                                       const MCRelaxableFragment *DF,
                                       const MCAsmLayout &Layout) const {
  MCValue Target;
  uint64_t Value;
  bool Resolved = evaluateFixup(Layout, Fixup, DF, Target, Value);
  if (Target.getSymA() &&
      Target.getSymA()->getKind() == MCSymbolRefExpr::VK_X86_ABS8 &&
      Fixup.getKind() == FK_Data_1)
    return false;
  return getBackend().fixupNeedsRelaxationAdvanced(Fixup, Resolved, Value, DF,
                                                   Layout);
}
bool MCAssembler::fragmentNeedsRelaxation(const MCReplaceableFragment *IF, const MCAsmLayout &Layout) const {

    MCReplaceableFragment *fragment = const_cast<MCReplaceableFragment*>(IF);

    //if the targetSymbol is in the same page of this one
    if(fragment->getTheAlternativeState()){
        if (!getBackend().mayNeedRelaxation(fragment->getSecondPairJMP()))
            return false;
    } else if(!fragment->isFallThrough()){
        if (!getBackend().mayNeedRelaxation(fragment->getInst()))
            return false;
    } else{
        return false;
    }

    for (const MCFixup &Fixup : fragment->getFixups())
        if (fixupNeedsRelaxation(Fixup, fragment, Layout))
            return true;

    return false;
}

bool MCAssembler::fragmentNeedsRelaxation(const MCRelaxableFragment *F,
                                          const MCAsmLayout &Layout) const {
  // If this inst doesn't ever need relaxation, ignore it. This occurs when we
  // are intentionally pushing out inst fragments, or because we relaxed a
  // previous instruction to one that doesn't need relaxation.
  if (!getBackend().mayNeedRelaxation(F->getInst()))
    return false;

  for (const MCFixup &Fixup : F->getFixups())
    if (fixupNeedsRelaxation(Fixup, F, Layout))
      return true;

  return false;
}

bool MCAssembler::relaxReplaceInstruction(MCAsmLayout &Layout, MCReplaceableFragment &IF) {
    //1. check whether this fragment need adjust
    if(!fragmentNeedsRelaxation(&IF,Layout))
        return false;

    MCInst Relaxed;
    SmallVector<MCFixup, 4> Fixups;
    SmallString<256> Code;
    raw_svector_ostream VecOS(Code);

    //2. lower the instruciton
    if(IF.getTheAlternativeState()){
        //a.generate mov
        getEmitter().encodeInstruction(IF.getSecondPairMOV(), VecOS, Fixups, IF.getSubtargetInfo());
        IF.getContents() = Code;
        IF.getFixups() = Fixups;

        Code.clear();
        Fixups.clear();
        //b.generate jmp
        getBackend().relaxInstruction(IF.getSecondPairJMP(), IF.getSubtargetInfo(), Relaxed);
        Relaxed.getOperand(0).setExpr(MCSymbolRefExpr::create(currentJMP,getContext()));
        getEmitter().encodeInstruction(Relaxed, VecOS, Fixups, IF.getSubtargetInfo());
//        errs()<<"IFX:"<<IF.getFixups().size()<<"\n";
//        errs()<<"IFX:"<<IF.getContents().size()<<"\n";
        for (unsigned i = 0, e = Fixups.size(); i != e; ++i) {
            Fixups[i].setOffset(Fixups[i].getOffset() + IF.getContents().size());
            IF.getFixups().push_back(Fixups[i]);
        }
        IF.getContents().append(Code.begin(), Code.end());
        IF.setSecondPairOfInst(IF.getSecondPairMOV(),Relaxed);
//        errs()<<"IFX:"<<IF.getFixups().size()<<"\n";
//        errs()<<"IFX:"<<IF.getContents().size()<<"\n";

    } else{
        getBackend().relaxInstruction(IF.getInst(), IF.getSubtargetInfo(), Relaxed);
        getEmitter().encodeInstruction(Relaxed, VecOS, Fixups, IF.getSubtargetInfo());

        //4. update the fragment.
        IF.setInst(Relaxed);
        IF.getContents() = Code;
        IF.getFixups() = Fixups;
    }

    return true;
}

bool MCAssembler::relaxInstruction(MCAsmLayout &Layout,
                                   MCRelaxableFragment &F) {
  if (!fragmentNeedsRelaxation(&F, Layout))
    return false;

  ++stats::RelaxedInstructions;

  // FIXME-PERF: We could immediately lower out instructions if we can tell
  // they are fully resolved, to avoid retesting on later passes.

  // Relax the fragment.

  MCInst Relaxed;
  getBackend().relaxInstruction(F.getInst(), F.getSubtargetInfo(), Relaxed);

  // Encode the new instruction.
  //
  // FIXME-PERF: If it matters, we could let the target do this. It can
  // probably do so more efficiently in many cases.
  SmallVector<MCFixup, 4> Fixups;
  SmallString<256> Code;
  raw_svector_ostream VecOS(Code);
  getEmitter().encodeInstruction(Relaxed, VecOS, Fixups, F.getSubtargetInfo());

  // Update the fragment.
  F.setInst(Relaxed);
  F.getContents() = Code;
  F.getFixups() = Fixups;

  return true;
}

bool MCAssembler::relaxLEB(MCAsmLayout &Layout, MCLEBFragment &LF) {
  uint64_t OldSize = LF.getContents().size();
  int64_t Value;
  bool Abs = LF.getValue().evaluateKnownAbsolute(Value, Layout);
  if (!Abs)
    report_fatal_error("sleb128 and uleb128 expressions must be absolute");
  SmallString<8> &Data = LF.getContents();
  Data.clear();
  raw_svector_ostream OSE(Data);
  if (LF.isSigned())
    encodeSLEB128(Value, OSE);
  else
    encodeULEB128(Value, OSE);
  return OldSize != LF.getContents().size();
}

bool MCAssembler::relaxDwarfLineAddr(MCAsmLayout &Layout,
                                     MCDwarfLineAddrFragment &DF) {
  MCContext &Context = Layout.getAssembler().getContext();
  uint64_t OldSize = DF.getContents().size();
  int64_t AddrDelta;
  bool Abs = DF.getAddrDelta().evaluateKnownAbsolute(AddrDelta, Layout);
  assert(Abs && "We created a line delta with an invalid expression");
  (void) Abs;
  int64_t LineDelta;
  LineDelta = DF.getLineDelta();
  SmallString<8> &Data = DF.getContents();
  Data.clear();
  raw_svector_ostream OSE(Data);
  MCDwarfLineAddr::Encode(Context, getDWARFLinetableParams(), LineDelta,
                          AddrDelta, OSE);
  return OldSize != Data.size();
}

bool MCAssembler::relaxDwarfCallFrameFragment(MCAsmLayout &Layout,
                                              MCDwarfCallFrameFragment &DF) {
  MCContext &Context = Layout.getAssembler().getContext();
  uint64_t OldSize = DF.getContents().size();
  int64_t AddrDelta;
  bool Abs = DF.getAddrDelta().evaluateKnownAbsolute(AddrDelta, Layout);
  assert(Abs && "We created call frame with an invalid expression");
  (void) Abs;
  SmallString<8> &Data = DF.getContents();
  Data.clear();
  raw_svector_ostream OSE(Data);
  MCDwarfFrameEmitter::EncodeAdvanceLoc(Context, AddrDelta, OSE);
  return OldSize != Data.size();
}

bool MCAssembler::relaxCVInlineLineTable(MCAsmLayout &Layout,
                                         MCCVInlineLineTableFragment &F) {
  unsigned OldSize = F.getContents().size();
  getContext().getCVContext().encodeInlineLineTable(Layout, F);
  return OldSize != F.getContents().size();
}

bool MCAssembler::relaxCVDefRange(MCAsmLayout &Layout,
                                  MCCVDefRangeFragment &F) {
  unsigned OldSize = F.getContents().size();
  getContext().getCVContext().encodeDefRange(Layout, F);
  return OldSize != F.getContents().size();
}
int MCAssembler::getFragmentSize(MCFragment *itr, int PageSize,int BlockSize,int PageConstantSize,int *BlockGenreatedConstantSize,std::map<const MCSymbol*, MCMBBConstantFragment*> & tempMAP) {
    int size=0;
    switch(itr->getKind()){
        default:
            errs()<<__func__<<" "<<itr->getKind()<<" kind we do not have handled\n";
            break;
        case MCFragment::FT_Constant:{
                MCMBBConstantFragment * fragment = cast<MCMBBConstantFragment>(itr);
                const MCSymbol *symbol = fragment->getConstantSymbol();
                auto itr = currentConstentMap.find(symbol);
                if(itr==currentConstentMap.end()){
                    tempMAP.insert(std::make_pair(symbol,fragment));

                    unsigned align = fragment->getAlign();
                    //1. align the data
                    if(align!=0){
                        int generatedSize = PageConstantSize + *BlockGenreatedConstantSize;
                        unsigned fillZeroSize = (12+generatedSize+ align-1) & ~(align-1);
                        fillZeroSize-=(12+generatedSize);
                        size += fillZeroSize;
                    }
                    size += fragment->getConstantSize();
                    *BlockGenreatedConstantSize += size;
                    return 0;
                }
            break;
        }
        case MCFragment::FT_Align:
        case MCFragment::FT_MBBegin:{
            const MCAlignFragment &AF = cast<MCAlignFragment>(*itr);
            unsigned Offset = PageSize+PageConstantSize+BlockSize;
            size = OffsetToAlignment(Offset, AF.getAlignment());
            // If we are padding with nops, force the padding to be larger than the
            // minimum nop size.
            if (size > 0 && AF.hasEmitNops()) {
                while (size % getBackend().getMinimumNopSize())
                    size += AF.getAlignment();
            }
        }
            break;
        case MCFragment::FT_MBEnd:{
            size=cast<MCReplaceableFragment>(itr)->getContents().size();
            MCReplaceableFragment *fragment = cast<MCReplaceableFragment>(itr);
            if(!(fragment->isFallThrough() && !fragment->getTheAlternativeState())){
                size += 4;
            }
        }
            break;
        case MCFragment::FT_Data:
            size= cast<MCDataFragment>(itr)->getContents().size();
            break;
        case MCFragment::FT_Relaxable:
            size= cast<MCRelaxableFragment>(itr)->getContents().size();
            size+=4;
            break;
    }
    return size;
}

void MCAssembler::insertConstantFragment(MCAsmLayout &Layout, MCSection &Section) {
    if(currentConstentMap.size()==0)
        return;

    MCDataFragment *dataFragment = currentMCAsmPage->getConstantFragment();
    char buffZero[16]={0};

    for(auto itr:currentConstentMap){
        const MCSymbol * symbol = itr.first;
        MCMBBConstantFragment *fragment = itr.second;
        unsigned align = fragment->getAlign();
        //1. align the data
        if(align!=0){
            int generatedSize = dataFragment->getContents().size();
            unsigned fillZeroSize = (12+generatedSize+ align-1) & ~(align-1);
            fillZeroSize-=(12+generatedSize);
//        int fillZeroSize = align - ((8+generatedSize)&(align-1));
//            errs()<<"current offset:"<<generatedSize+8<<" align:"<<align<<" generated zeor:"<<fillZeroSize<<"\n";
            auto zero = StringRef(buffZero,fillZeroSize);
            dataFragment->getContents().append(zero.begin(),zero.end());
        }



//        unsigned NewOffset = (Offset + AlignMask) & ~AlignMask;
//        OutStreamer->EmitZeros(NewOffset - Offset);


        fragment->setPageIndex(currentMCAsmPage->getPageIndex());
        MCSymbol * newSymbol = getContext().getOrCreateSymbol(Twine(symbol->getName())+ "_page_" + Twine(fragment->getPageIndex()));
        newSymbol->setOffset(dataFragment->getContents().size());
        newSymbol->setFragment(dataFragment);
        orgToNewSymbolMap.insert(std::make_pair(symbol,newSymbol));

        //copy the content
        // 1. get the original fragment's content
        if(symbol->getFragment()->getKind()==MCFragment::FT_Data){
            MCDataFragment *orgFragment = cast<MCDataFragment>(symbol->getFragment());
            int size = fragment->getConstantSize();
            int offset = symbol->getOffset();
            int realSize = orgFragment->getContents().size();


            auto contentItr= orgFragment->getContents().begin();
//            int compare = dataFragment->getContents().size();
            dataFragment->getContents().append(contentItr+offset,contentItr+offset+realSize);

            if(size!=realSize){
                int leftSize = size - realSize;
                MCSection::iterator begin = symbol->getSection().getFragmentList().begin();
                MCSection::iterator end =symbol->getSection().getFragmentList().end();
                while ((&*begin)!=symbol->getFragment()){ begin++;}
                assert(symbol->getFragment()==(&*begin) && "begin is the start");
                begin++;
                for(;begin!=end && leftSize!=0;begin++){
                    switch (begin->getKind()){
                        case MCFragment::FT_Data:{
                            MCDataFragment *curDataFragment = cast<MCDataFragment>(begin);
                            int fragmentSize = curDataFragment->getContents().size();
                            if(leftSize > fragmentSize){
                                dataFragment->getContents().append(curDataFragment->getContents().begin(),curDataFragment->getContents().end());
                                leftSize -= fragmentSize;
                            } else{
                                dataFragment->getContents().append(curDataFragment->getContents().begin(),curDataFragment->getContents().begin()+leftSize);
                                leftSize = 0;
                            }
                            break;
                        }
                        case MCFragment::FT_Fill:{
                            MCFillFragment *curFillFragment = cast<MCFillFragment>(begin);
                            int fragmentSize = curFillFragment->getSize();
                            if(leftSize > fragmentSize){
                                dataFragment->getContents().append(fragmentSize,buffZero[0]);
                                leftSize -=fragmentSize;
                            } else{
                                dataFragment->getContents().append(leftSize,buffZero[0]);
                                leftSize=0;
                            }
                            break;
                        }
                        default:
                            errs()<<" KIND "<<begin->getKind()<<"\n";
                    }


                }

            }






        } else{
            exit(-1);
        }

    }

    unsigned currentSize = dataFragment->getContents().size()+8;
    unsigned size = 16 - (currentSize % 16);
    if(size < 16){
        auto zero = StringRef(buffZero,size);
        dataFragment->getContents().append(zero.begin(),zero.end());
    }

}

bool MCAssembler::calculateApage(MCAsmLayout &Layout, MCSection &Section, MCSection::iterator start,
                                 MCSection::iterator &endItr) {

    //Page should start with a FT_MBBegin instruciton
    while(start->getKind()!=MCFragment::FT_MBBegin){
        start++;
    }

    int pageContentSize =8;
    int blockSize=0;
    MCSection::iterator lastMBBeginItrRecord=start;
    int shadowPageSize = (1<<currentMCAsmPage->getPageAlign()); 
    MCSection::iterator itr=start;
    itr++;
    currentConstentMap.clear();
    std::map<const MCSymbol*, MCMBBConstantFragment*> tempConstentMap;
//    int blockNum=0;
    int blockGeneratedConstant=0;
    int pageConstantSize=0;
    bool needReCalculate=false;
    int MBBeginNum=1;
    for(;itr!=endItr && itr!=Section.end();itr++){
        if(itr->getKind()==MCFragment::FT_MBBegin){
            //to be conversative
            if((pageContentSize+blockSize+pageConstantSize+blockGeneratedConstant+0x20)>shadowPageSize){
                if(blockSize>shadowPageSize){
//                    errs()<<"new pageContentSize: "<<pageContentSize<<" pageConstantSize:"<<pageConstantSize<<"\n";
//                    errs()<<"blockSize: "<<blockSize<<" blockGeneratedConstant:"<<blockGeneratedConstant<<"\n";
                    break;
                }
                needReCalculate=true;
//                errs()<<__LINE__<<pageContentSize+blockSize+pageConstantSize+blockGeneratedConstant<<"\n";
//                errs()<<"pageContentSize: "<<pageContentSize<<" pageConstantSize:"<<pageConstantSize<<"\n";
//                errs()<<"blockSize: "<<blockSize<<" blockGeneratedConstant:"<<blockGeneratedConstant<<"\n";
                break;
            }
            MBBeginNum++;
            //add the BB into the page
            pageContentSize +=blockSize;
            pageConstantSize +=blockGeneratedConstant;
            //reset the state
            blockSize=0;
            blockGeneratedConstant=0;
            lastMBBeginItrRecord=itr;
//            errs()<<"lastMBBeginItrRecord "<<lastMBBeginItrRecord->getLayoutOrder()<<"\n";
            for(auto itrz:tempConstentMap){
                currentConstentMap.insert(itrz);
            }
            tempConstentMap.clear();
        } else if(itr->getKind()==MCFragment::FT_MBEnd){
            MCReplaceableFragment *replaceableFragment = cast<MCReplaceableFragment>(itr);
            MCSymbol *targetMBB = const_cast<MCSymbol*>(replaceableFragment->getTargetMBB());
            if(currentMCAsmPage->consultSymbolInPage(targetMBB)){
                //we find the target in this page, so we chose the near jmp
                replaceableFragment->setIsTheAlternativeChoice(false);
            } else{
                //otherwise, we chose the second one dereference the instruction before it jmp
                replaceableFragment->setIsTheAlternativeChoice(true);
            }
        }else if(itr->getKind()==MCFragment::FT_Data){
            //handle loop
            bool needBreak=false;
          if(cast<MCDataFragment>(itr)->getIsEntryOfAloop()){
              MCDataFragment *fragment = cast<MCDataFragment>(itr);

              for(auto fragmentItr:fragment->getDominateNodes()){
                  MCReplaceableFragment *fragmentMBBEnd = cast<MCReplaceableFragment>(fragmentItr);
//                   const MCSymbol * currentMBSymbol = fragmentMBBEnd->getTargetMBB();
                  int loopSize=0;
                  int loopConstantSize=blockGeneratedConstant;
                  std::map<const MCSymbol*, MCMBBConstantFragment*> temp1;
                  bool isNotIncluded=false;
                  for (MCSection::iterator itrI=itr;itrI!=itr->getParent()->end();itrI++){
                      if(itrI==endItr) isNotIncluded = true;
                      loopSize+=getFragmentSize(&*itrI,pageContentSize,blockSize,pageConstantSize,&loopConstantSize,temp1);
                      if(&*fragmentItr==&*itrI)break;
                  }
                  //handle loop less than shadowPageSize/4
                  if(isNotIncluded && loopSize<(shadowPageSize/4)){
                      int tempsize=pageContentSize+pageConstantSize+loopSize+loopConstantSize;
                      if((tempsize>shadowPageSize) && (tempsize-shadowPageSize)<shadowPageSize/8){
                          needBreak=true;
                          break;
                      }
                  }
                  //handle loop more than shadowPageSize
                  if((loopSize+loopConstantSize)>shadowPageSize){

                      int leftSize = (loopSize+loopConstantSize)%shadowPageSize;
                      if((leftSize>(shadowPageSize*3/4)) && (pageContentSize+pageConstantSize+leftSize)>shadowPageSize){

                          if(MBBeginNum!=1){
                              needBreak=true;
                              break;
                          }
                      }
                  }

              }

          }
            if(needBreak){
                needReCalculate=true;
                break;
            }

        }
        blockSize+=getFragmentSize(&*itr,pageContentSize,blockSize,pageConstantSize,&blockGeneratedConstant,tempConstentMap);
    }

    if((pageContentSize+blockSize+pageConstantSize+blockGeneratedConstant)>shadowPageSize){
        if(blockSize>shadowPageSize){
            needReCalculate=false;
        }else{
            needReCalculate=true;
        }

    }else{
        for(auto itrz:tempConstentMap){
            currentConstentMap.insert(itrz);
        }
    }

//    errs()<<"current page Index"<<currentMCAsmPage->getPageIndex()<<"\n";
    //if the itr not equals to the endItr, we have some symbols to clear form current page's map
    if(needReCalculate){
        for(itr=lastMBBeginItrRecord;itr!=endItr;itr++){
            if(itr->getKind()==MCFragment::FT_MBBegin){
                MCSymbol *symbol = cast<MCBBStartFragment>(itr)->getBBSymbol();
                currentMCAsmPage->removeSymbolFromPage(symbol);
            }
        }
        endItr=lastMBBeginItrRecord;
        return false;
    }
    return true;

}
bool MCAssembler::perCalculateAPage(MCAsmLayout &Layout,MCSection &curSection, MCSection::iterator &start,
                                                   MCSection::iterator &SectionEnd) {
    //Page should start with a FT_MBBegin instruciton
    while(start!=SectionEnd && start->getKind()!=MCFragment::FT_MBBegin ){
        start++;
    }

    if(start == SectionEnd){
        return false;
    }
    MCSymbol *MBB=cast<MCBBStartFragment>(start)->getBBSymbol();

    auto pair = MCAsmPageMap.find(MBB);
    //if the page has already created, we should ignore the perCalculated
    if(pair!=MCAsmPageMap.end()){
        start=SectionEnd;
        return false;
    }
    currentConstentMap.clear();
    orgToNewSymbolMap.clear();

    //create a new page
    currentMCAsmPage = new MCAsmPage(++stats::RelaxedInstructions);
    MCAsmPageList.push_back(currentMCAsmPage);
    MCAsmPageMap.insert(std::make_pair(MBB,currentMCAsmPage));
    cast<MCBBStartFragment>(start)->setAligment(1<<(currentMCAsmPage->getPageAlign()));
    cast<MCBBStartFragment>(start)->setAsPageStart();
    int shadowPageSize= (1<<(currentMCAsmPage->getPageAlign()));

    char ORAMIndex[4]={0,0,(char)0x90,(char)0x90};
    *(u_int32_t *)ORAMIndex = (u_int32_t )currentMCAsmPage->getPageIndex();

    //then we should insert a in-page jmp fragment for the page
    MCSymbol * inPageJmp=getContext().getOrCreateSymbol("MCASM_IN_PAGE_JMP"+Twine(currentMCAsmPage->getPageIndex()));
    MCSymbol * orgJmpTemp = getContext().getOrCreateSymbol("MCASM_IN_PAGE_JMP");
    if(orgJmpTemp && inPageJmp){
        MCRelaxableFragment * orgJMPTempFragment= cast<MCRelaxableFragment>(orgJmpTemp->getFragment());

        auto ORAMIndexString = StringRef(ORAMIndex,4);
        MCDataFragment *dataFragment=new MCDataFragment();
        dataFragment->getContents().append(ORAMIndexString.begin(),ORAMIndexString.end());
        dataFragment->getContents().append(orgJMPTempFragment->getContents().begin(),orgJMPTempFragment->getContents().end());
        curSection.getFragmentList().insertAfter(start,dataFragment);
        dataFragment->setParent(&curSection);
        //set the inPageJmp symbol
        inPageJmp->setFragment(dataFragment);
        inPageJmp->setOffset(4);
        currentJMP=inPageJmp;

        //align the code
        MCSection::iterator temp=start;
        ++temp;

        MCAlignFragment *af= new MCAlignFragment(4,0x90,1,4);
        curSection.getFragmentList().insertAfter(temp,af);
        af->setParent(&curSection);


        ++temp;
        MCDataFragment *constantFragment =new MCDataFragment();
        curSection.getFragmentList().insertAfter(temp,constantFragment);
        constantFragment->setParent(&curSection);
        currentMCAsmPage->setConstantFragment(constantFragment);

        //reset the fragments order
        unsigned FragmentIndex = start->getLayoutOrder();
        for (MCSection::iterator itr=start;itr!=SectionEnd;itr++)
            itr->setLayoutOrder(FragmentIndex++);
    }

    int sizeOfContentsInAPage=0; //the size of the content in current page
    int blockSize=0;
    MCSection::iterator lastMBBeginItrRecord=start;
    //add symbols to the page as many as possible
    MCSection::iterator I=start;
    I++;
    int bbConstantSize=0;
    int pageConstantSize=0;
    std::map<const MCSymbol*, MCMBBConstantFragment*> tempConstentMap;
    int curMBBeginNum=1;
    for (; I != SectionEnd; ++I) {
        if(I->getKind()==MCFragment::FT_MBBegin){
            if((sizeOfContentsInAPage+blockSize+pageConstantSize+bbConstantSize)>=shadowPageSize){
                if(curMBBeginNum==1){
                    //current MBB bigger than 1 shadow page
                    for(auto itr:tempConstentMap){
                        currentConstentMap.insert(itr);
                    }
                    tempConstentMap.clear();
                    start=I;
                }
//                errs()<<" current pagesize:"<<sizeOfContentsInAPage<<" block size:"<<blockSize<<" overall:"<<sizeOfContentsInAPage+blockSize<<"\n";
                break;
            }
            curMBBeginNum++;

            //add the BB into the page
            MCSymbol *mcSymbol = cast<MCBBStartFragment>(lastMBBeginItrRecord)->getBBSymbol();
            currentMCAsmPage->addSymbolToPage(mcSymbol);
//            errs()<<"Pageindex:"<<currentMCAsmPage->getPageIndex()<<" add "<<cast<MCBBStartFragment>(lastMBBeginItrRecord)->getFIndex();
            sizeOfContentsInAPage+=blockSize;
            pageConstantSize+=bbConstantSize;
//            errs()<<" blocksize:"<<blockSize<<" size:"<<sizeOfContentsInAPage<<"\n";

            //reset the state
            blockSize=0;
            bbConstantSize=0;
            lastMBBeginItrRecord=I;
            for(auto itr:tempConstentMap){
                currentConstentMap.insert(itr);
            }
            tempConstentMap.clear();
        }
        if(I->getKind()==MCFragment::FT_Constant){
            cast<MCMBBConstantFragment>(I)->setPageIndex(currentMCAsmPage->getPageIndex());
        }

        blockSize+=getFragmentSize(&*I,sizeOfContentsInAPage,blockSize,pageConstantSize,&bbConstantSize,tempConstentMap);
    }

    if(I==SectionEnd && (sizeOfContentsInAPage+blockSize)<=shadowPageSize){
        //add the BB into the page
        MCSymbol *mcSymbol = cast<MCBBStartFragment>(lastMBBeginItrRecord)->getBBSymbol();
        currentMCAsmPage->addSymbolToPage(mcSymbol);
        lastMBBeginItrRecord=SectionEnd;
    }
    if(curMBBeginNum!=1){
        start = lastMBBeginItrRecord;
    }
    return true;
}

bool MCAssembler::layoutSectionOnce(MCAsmLayout &Layout, MCSection &Sec) {
  // Holds the first fragment which needed relaxing during this layout. It will
  // remain NULL if none were relaxed.
  // When a fragment is relaxed, all the fragments following it should get
  // invalidated because their offset is going to change.
  int compare=1;
  MCFragment *FirstRelaxedFragment = nullptr;
  MCBBStartFragment *startFragment=nullptr;
  bool isTextSection = Sec.getBeginSymbol()->getName().startswith(".text");

  MCSection::iterator pageStartItr=Sec.begin();
  MCSection::iterator pageEndItr=Sec.end();
//  bool needCalcualteAPage = false;  //the calculate start from a MCBBStartFragment
  // Attempt to relax all the fragments in the section.
  for (MCSection::iterator I = Sec.begin(), IE = Sec.end(); I != IE; ++I) {
    if(isTextSection && I==pageStartItr){
        if(perCalculateAPage(Layout,Sec,pageStartItr,pageEndItr)){
            //calculateApage until a page fixed
            FirstRelaxedFragment = &*Sec.begin();
            while (!calculateApage(Layout,Sec,I,pageStartItr)){}
            //then we should insert new Constant fragment to the page
            insertConstantFragment(Layout,Sec);
        }

    }

    // Check if this is a fragment that needs relaxation. And we should add MBB into a page as many as possible.
    bool RelaxedFrag = false;
    switch(I->getKind()) {
    default:
        break;
    case MCFragment::FT_MBBegin:
        startFragment=dyn_cast_or_null<MCBBStartFragment>(&*I);
        if(startFragment){
            if(compare!=startFragment->getFIndex()){
                 errs()<<__func__<<" startFragment index: not right"<<compare<<" "<<startFragment->getFIndex()<<"\n";
            }
            compare++;

        }
      break;
    case MCFragment::FT_Constant:{

        MCMBBConstantFragment *constantFragment = cast<MCMBBConstantFragment>(I);
        const MCSymbol *orgSymbol = constantFragment->getConstantSymbol();
        MCSymbol *NSymbolInFragment = constantFragment->getNSymbol();
        auto itr = orgToNewSymbolMap.find(orgSymbol);
        if(itr!=orgToNewSymbolMap.end()){
            const MCSymbol *inPageNewSymbol = itr->second;
            NSymbolInFragment->setFragment(inPageNewSymbol->getFragment());
            NSymbolInFragment->setOffset(inPageNewSymbol->getOffset());
        }

//        if(fragment){
//            const MCSymbol *symbol = constantFragment->getConstantSymbol();
//
//            MCValue Target;
//            uint64_t Value;
//            bool iscorrect=false;
//            for(auto itr:fragment->getFixups()){
//                const MCExpr *Expr = itr.getValue();
//                Expr->evaluateAsRelocatable(Target, &Layout, &itr);
//                if (const MCSymbolRefExpr *A = Target.getSymA()) {
//                    const MCSymbol &Sym = A->getSymbol();
//                    if (Sym.isDefined() && Sym.getName().equals(symbol->getName())){
//                        MCSymbol *constantSymbol=getContext().getOrCreateSymbol(Twine(symbol->getName())+"_page_"+Twine(constantFragment->getPageIndex()));
////                        errs()<<__func__<<" new symbol name: "<<constantSymbol->getName()<<"\n";
//                        if(constantSymbol->isDefined()){
//                            iscorrect=true;
//                        }
//                    }
//
//                }
//            }
//            if(!iscorrect){
//                errs()<<__func__<<" not find symbol name: "<<symbol->getName()<<"\n";
//            }
//
//        }
    }
            break;
    case MCFragment::FT_MBEnd:
      RelaxedFrag = relaxReplaceInstruction(Layout,*cast<MCReplaceableFragment>(I));
      break;
    case MCFragment::FT_Relaxable:
      assert(!getRelaxAll() &&
             "Did not expect a MCRelaxableFragment in RelaxAll mode");
      RelaxedFrag = relaxInstruction(Layout, *cast<MCRelaxableFragment>(I));
      break;
    case MCFragment::FT_Dwarf:
      RelaxedFrag = relaxDwarfLineAddr(Layout,
                                       *cast<MCDwarfLineAddrFragment>(I));
      break;
    case MCFragment::FT_DwarfFrame:
      RelaxedFrag =
        relaxDwarfCallFrameFragment(Layout,
                                    *cast<MCDwarfCallFrameFragment>(I));
      break;
    case MCFragment::FT_LEB:
      RelaxedFrag = relaxLEB(Layout, *cast<MCLEBFragment>(I));
      break;
    case MCFragment::FT_CVInlineLines:
      RelaxedFrag =
          relaxCVInlineLineTable(Layout, *cast<MCCVInlineLineTableFragment>(I));
      break;
    case MCFragment::FT_CVDefRange:
      RelaxedFrag = relaxCVDefRange(Layout, *cast<MCCVDefRangeFragment>(I));
      break;
    }
    if (RelaxedFrag && !FirstRelaxedFragment)
      FirstRelaxedFragment = &*I;
  }
  if (FirstRelaxedFragment) {
    Layout.invalidateFragmentsFrom(FirstRelaxedFragment);
    return true;
  }
  return false;
}

bool MCAssembler::layoutOnce(MCAsmLayout &Layout) {
  ++stats::RelaxationSteps;

  bool WasRelaxed = false;
  for (iterator it = begin(), ie = end(); it != ie; ++it) {
    MCSection &Sec = *it;
    errs()<<"we start from:"<<Sec.getBeginSymbol()->getName()<<"\n";
    while (layoutSectionOnce(Layout, Sec))
      WasRelaxed = true;
  }

  return WasRelaxed;
}

void MCAssembler::finishLayout(MCAsmLayout &Layout) {
  // The layout is done. Mark every fragment as valid.
  for (unsigned int i = 0, n = Layout.getSectionOrder().size(); i != n; ++i) {
    MCSection &Section = *Layout.getSectionOrder()[i];
    Layout.getFragmentOffset(&*Section.rbegin());
    computeFragmentSize(Layout, *Section.rbegin());
  }
  getBackend().finishLayout(*this, Layout);
}
