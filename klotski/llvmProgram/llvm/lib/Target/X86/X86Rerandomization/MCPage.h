#ifndef LLVM_MC_MCPAGE_H
#define LLVM_MC_MCPAGE_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/ilist_node.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/ilist.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCFragment.h"
#include "llvm/MC/SectionKind.h"
#include "llvm/Support/SMLoc.h"
#include "llvm/Support/Allocator.h"
#include <cstdint>
#include <utility>
#include <string>
#include <vector>

namespace llvm{
    class MCSection;
    class MCFragment;
    class MCSymbol;

    class MCPage: public ilist_node_with_parent<MCPage, MCSection> {
        friend class MCAsmLayout;
    public:
        enum PageType: uint8_t{
            PG_CODE,
            PG_DATA
        };
        typedef std::vector<MCFragment *> FragmentListPtrType;
       // typedef StringMap<MCSymbol *,BumpPtrAllocator &> PageSymbolTable;

        typedef FragmentListPtrType::iterator iterator;
        typedef FragmentListPtrType::reverse_iterator reverse_iterator;

        MCPage(PageType Kind,MCSection *ParentSection, unsigned ordinal);
        ~MCPage()= default;
    private:
        unsigned pageWide;
        unsigned long pageSize;
        PageType Kind;
        MCSection *ParentSection;
        int remainSize;
        /// The index in the assemblers section pagelist.
        unsigned Ordinal;
        //Fragments in this page
        FragmentListPtrType Fragments;
        //adjacent page numbers, if the function is more than 1 page, we may need this
        int adjPageNum;

    public:
        unsigned getPageWide(){ return pageWide;}
        unsigned getPageSize(){ return pageSize;}
        PageType getKind() const { return Kind;}
        ///get page index in section
        unsigned getPageIndex(){
            return Ordinal;
        }

        int getRemainSize(){ return remainSize;}
        void setRemainSize(int val){ remainSize=val;}
        int getAdjPageNum(){return adjPageNum;}
        int setAdjPageNum(int i){return adjPageNum=i;}

        MCPage::FragmentListPtrType &getFragmentList() { return Fragments; }
        const MCPage::FragmentListPtrType &getFragmentList() const {
            return const_cast<MCPage*>(this)->getFragmentList();
        }

        MCSection * getParent(){ return ParentSection;}
        void setParent(MCSection *MCS){ParentSection=MCS;}

        iterator begin() { return Fragments.begin(); }
        iterator end() { return Fragments.end(); }

        reverse_iterator rbegin() { return Fragments.rbegin(); }
        reverse_iterator rend() { return Fragments.rend(); }
        void reset(){
            while (Fragments.begin()!=Fragments.end()){
                Fragments.pop_back();
            }
        }

        void destroy();
    };
    class MCCodePage : public MCPage {
    public:
        MCCodePage(MCSection *codeSection, unsigned oridinal):
                MCPage(PG_CODE,codeSection,oridinal){}

        typedef std::vector<MCSymbol *> FunSymbolListPtrType;
        typedef FunSymbolListPtrType::iterator func_symbol_iterator;
        typedef FunSymbolListPtrType::reverse_iterator func_symbol_reverse_iterator;


    private:
        // FuncSymbolTable SymbolTable;
        PageType Kind;
        FunSymbolListPtrType FunctionSymbols;

    public:

        FunSymbolListPtrType getFunctionSymbols(){ return FunctionSymbols;}
        //iterator functionSymbol
        func_symbol_iterator funcSymbolBegin(){ return FunctionSymbols.begin();}
        func_symbol_iterator funcSymbolEnd(){return FunctionSymbols.end();}
        void addFunctionSymbol(MCSymbol *mcFuncSymbol){
            FunctionSymbols.push_back(mcFuncSymbol);
        }
        void reset(){
            FunctionSymbols.clear();
            MCPage::reset();
        }

        static bool classof(const MCPage *F){ return F->getKind()== PG_CODE;}
    };

    class MCDataPage:public MCPage{
    public:
        MCDataPage(MCSection *dataSection, unsigned oridnal):
                MCPage(PG_DATA,dataSection,oridnal){}

        static bool classof(const MCPage *F){ return F->getKind()==PG_DATA;}
    };
}



#endif // LLVM_MC_MCFRAGMENT_H

