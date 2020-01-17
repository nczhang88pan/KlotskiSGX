//
// Created by alax on 5/3/17.
//
//#include "replaceRBPwithRSPinMOV.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCFragment.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCSymbol.h"
#include "MCPage.h"
using namespace llvm;
void ilist_alloc_traits<MCPage>::deleteNode(MCPage *V) { V->destroy(); }

MCPage::MCPage(PageType Kind,MCSection *ParentSection, unsigned ordinal)
        :ParentSection(ParentSection),Ordinal(ordinal),Kind(Kind),adjPageNum(1),pageWide(11)
{
    pageSize = 1 << pageWide;
    remainSize = 1 << pageWide;
    if(ParentSection)
        ParentSection->getPageList().push_back(this);
}

void MCPage::destroy() {
    if(Kind == PageType(~0)){
        delete this;
        return;
    }
    switch (Kind){
        case PG_CODE:
            delete cast<MCCodePage>(this);
            return;
        case PG_DATA:
            delete cast<MCDataPage>(this);
            return;
    }
}



