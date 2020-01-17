//
// Created by alax on 6/11/18.
//
#include "DataAnalysis.h"
#include "unSafeObject.h"
#include "klotskiConfig.h"
namespace llvm{
    bool isfuncNeedHandle(StringRef functionName){
        if( functionName.startswith("memmove")
            ||functionName.startswith("memset")
            ||functionName.startswith("memcpy"))
            return true;
        return false;
    }

    DataFlow::~DataFlow(){
        for(auto itr:dataFlowResult.result){
            BlockResult* temp = itr.second;
            dataFlowResult.result[itr.first]= nullptr;
            delete temp;
        }
        for(auto itr:dataFlowResult.loopResults){
            LoopResult *temp = itr.second;
            dataFlowResult.loopResults[itr.first]= nullptr;
            delete temp;
        }
        dataFlowResult.result.clear();
        dataFlowResult.loopResults.clear();
    }

    bool DataFlow::isRandomPoint(Instruction *I, Value *calledFunction, std::vector<Value *> &noneRandomPointSet) {
        //in klotski all functions are handled as a RandomPoint
//       return true;
       CallInst *CI = dyn_cast<CallInst>(&*I);
       if(CI->isInlineAsm())
           return false;
        return true;
        //Value *calledFunction = CI->getCalledValue();
        if(isa<MemIntrinsic>(&*I)){
            return false;
        } else if(isa<VACopyInst>(&*I)){
            return false;
        } else if(isa<VAStartInst>(&*I)){
            return false;
        }
        if(calledFunction->hasName()){
            StringRef funcname = calledFunction->getName();
            if(isfuncNeedHandle(funcname)){
                return false;
            } else{
                if(calledFunction->getName().startswith("llvm."))return false;
                if(funcname.startswith("addressDereference")) return false;
            }
            //if(funcname.startswith("randomPointer")) return true;
            for(unsigned i=0;i<safeFunctions.size();i++){
                if(calledFunction->getName()==safeFunctions[i]){
                    return false;
                }
            }
        }

        return true;
    }
    DataFlowResult* DataFlow::init(Function &F,LoopInfo &LI,DominatorTree *DT,std::vector<Value*> &noneRandomPointSet) {
        SmallVector<BasicBlock*,4> funExitBlocks;
        SmallVector<BasicBlock*,16> loopExitBlocks;
        SmallVector<BasicBlock*,16> trackedBlocks; //track new generateBBs

        //calculate the need and gen set for each block
        for(Function::iterator BBI=F.begin(),BBE=F.end();BBI!=BBE;BBI++){
            trackedBlocks.push_back(&*BBI);
            BlockResult* blockResult = new BlockResult();
            blockResult->killed=false;
            for(BasicBlock::iterator IB=BBI->begin(),IE=BBI->end();IB!=IE;IB++){
                hanldInstructionToBuildUpNeedAndGen(IB,*blockResult,noneRandomPointSet);
            }

            dataFlowResult.result.insert(std::make_pair(&*BBI,blockResult));

            //record exit blocks
            const TerminatorInst *TInst = BBI->getTerminator();
            if(TInst->getNumSuccessors()==0){
                funExitBlocks.push_back(&*BBI);
            }
        }

        //init loopResult
        for (auto I = LI.begin(), IE = LI.end(); I != IE; ++I){
            for (auto L = df_begin(*I), LE = df_end(*I); L != LE; ++L){
                LoopResult *loopResult = new LoopResult();
                dataFlowResult.loopResults.insert(std::make_pair(*L,loopResult));
                initLoopResult(LI,*L);

                SmallVector<BasicBlock*,4> tempBBset;
                L->getExitBlocks(tempBBset);
                for(auto itr:tempBBset){
                    if(std::find(loopExitBlocks.begin(),loopExitBlocks.end(),itr)==loopExitBlocks.end()){
                        loopExitBlocks.push_back(itr);
                    }
                }
            }
        }
        //calculate the in and out
        SmallVector<BasicBlock*,32> worklist;
        //entry
        BasicBlock* entryBB = &F.getEntryBlock();
//        BlockResult *blockResult1=dataFlowResult.result[entryBB];
//        errs()<<"entry outObj\n";
//        for(auto itr:blockResult1->outObjs){
//            if(itr.second){
//                itr.first->print(errs());errs()<<"\n";
//            }
//        }
        worklist.push_back(entryBB);
        while (worklist.size()){
            BasicBlock *BB = worklist.pop_back_val();
            SmallVector<BlockResult*,4> preBasicBlockResult;
            for(pred_iterator PI = pred_begin(BB), PE = pred_end(BB);PI!=PE;PI++){
                preBasicBlockResult.push_back(dataFlowResult.result[*PI]);
            }
            if(mergeInAndUpdateOut(LI,BB,preBasicBlockResult,dataFlowResult.result[BB]) || BB==entryBB){
                const TerminatorInst *TInst = BB->getTerminator();
                for (unsigned I = 0, NSucc = TInst->getNumSuccessors(); I < NSucc; ++I) {
                    BasicBlock *Succ = TInst->getSuccessor(I);
                    worklist.push_back(Succ);
                }
            }
        }

        SmallVector<BasicBlock*,32> haveHandledBBSets;

        for(Function::iterator BBI= F.begin(),BBE=F.end();BBI!=BBE;BBI++){
            worklist.push_back(&*BBI);
        }
        //calculate the subNeed set
        for(auto exitBB:funExitBlocks){
            for(pred_iterator PI=pred_begin(exitBB),PE=pred_end(exitBB);PI!=PE;PI++){
                worklist.push_back(*PI);
            }
            worklist.push_back(exitBB);
        }
        while (worklist.size()){
            BasicBlock *BB = worklist.pop_back_val();
            if(std::find(haveHandledBBSets.begin(),haveHandledBBSets.end(),BB)==haveHandledBBSets.end()){
                haveHandledBBSets.push_back(BB);
            }

            //merge the needObjs of BB's subBBs into its subOBJs
//            bool existLoopExit=false;
            const TerminatorInst *TInst = BB->getTerminator();
            for (unsigned I = 0, NSucc = TInst->getNumSuccessors(); I < NSucc; ++I) {
                BasicBlock *Succ = TInst->getSuccessor(I);

                //ignore the loopExitBlock of a blocked loop
                if(std::find(loopExitBlocks.begin(),loopExitBlocks.end(),Succ)!=loopExitBlocks.end()){
                    Loop * loop = LI.getLoopFor(BB);

                    int preBBNum=0;
                    for(pred_iterator PI=pred_begin(Succ),PE=pred_end(Succ);PI!=PE;PI++){
                        ++preBBNum;
                    }

                    bool isBlockedLoop = false;
                    for(auto itr:loop->blocks()){
                        if(dataFlowResult.result[itr]->killed){
                            isBlockedLoop = true;
                        }
                    }
                    //if the preBB of succ is more than 1 and the loop is blocked, we need split it;
                    if(preBBNum>1 && isBlockedLoop){
                        //Succ->print(errs());errs()<<" PanzhanghandleBB";
                        //split the block
                        SplitEdge(BB,Succ,DT,&LI);
                        //we need to find all new generated Blocks;
                        SmallVector<BasicBlock*,2> newCreateBBs;
                        for(Function::iterator BI=F.begin(),BE=F.end();BI!=BE;BI++){
                            if(std::find(trackedBlocks.begin(),trackedBlocks.end(),&*BI)==trackedBlocks.end()){
                                newCreateBBs.push_back(&*BI);
                                trackedBlocks.push_back(&*BI);
                            }
                        }
                        while (newCreateBBs.size()){
                            //updata middleBB
                            BasicBlock * newBB = newCreateBBs.pop_back_val();

                            BasicBlock * succBB = newBB->getSingleSuccessor();
                            BlockResult* blockResult = new BlockResult();
                            blockResult->killed=false;
                            dataFlowResult.result.insert(std::make_pair(newBB,blockResult));
                            blockResult->needObjs.insert(dataFlowResult.result[succBB]->needObjs.begin(),
                                                         dataFlowResult.result[succBB]->needObjs.end());
                            blockResult->subBBneedObjs.insert(dataFlowResult.result[succBB]->needObjs.begin(),
                                                              dataFlowResult.result[succBB]->needObjs.end());
                            worklist.push_back(newBB);

//                            errs()<<"out new generate BB info\n";
//                            printResults(&dataFlowResult,newBB);
                        }

                        {
                            //recalculate the loopExitBlocks, it is the easiest way.
                            loopExitBlocks.clear();
                            for (auto I = LI.begin(), IE = LI.end(); I != IE; ++I){
                                for (auto L = df_begin(*I), LE = df_end(*I); L != LE; ++L){
                                    SmallVector<BasicBlock*,4> tempBBset;
                                    L->getExitBlocks(tempBBset);
                                    for(auto itr:tempBBset){
                                        if(std::find(loopExitBlocks.begin(),loopExitBlocks.end(),itr)==loopExitBlocks.end()){
                                            loopExitBlocks.push_back(itr);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //if current loop is blocked, we do not need to update the subneed
                    if(isBlockedLoop)
                        continue;
                }
                for(BasicBlock::iterator I = Succ->begin(),E = Succ->end();I!=E;I++){
                    PHINode *phiNode = dyn_cast<PHINode>(&*I);
                    if(!phiNode) break;

                    if(phiNode->getType()->isPointerTy()){
//                        int Idx = phiNode->getBasicBlockIndex(Succ);
//                        if(Idx<0){
//                            phiNode->print(errs());errs()<<"phi assert failed1\n";
//                        }
                        Value *value = phiNode->getIncomingValueForBlock(BB);
                        if(value){
                            //value->print(errs());errs()<<"Succ value\n";
                            dataFlowResult.result[BB]->subBBneedObjs[value]=value;
                        }
                    }
                }

                for(auto itr:dataFlowResult.result[Succ]->needObjs){
                    if(itr.second)
                        dataFlowResult.result[BB]->subBBneedObjs[itr.second]=itr.second;
                }
            }

            bool ischanged=false;
            if(dataFlowResult.result[BB]->killed) {

            }
//            else if(std::find(loopExitBlocks.begin(),loopExitBlocks.end(),BB)!=loopExitBlocks.end()){
//                //if BB is a loopExitBlock, we do not need to merge it with the need.
//            }
            else{
                //merge subObjs into needObjs exclude gen,and then clear the subObjs
                //SmallVector<Value*,32> subNeedOobjStash;
                for(auto itr: dataFlowResult.result[BB]->subBBneedObjs){
                    if(itr.second && !dataFlowResult.result[BB]->genObjs[itr.second]){
                        if(Instruction *I = dyn_cast<Instruction>(itr.second)){
                            if(I->getParent()==BB) continue;
                        }
                        if(!dataFlowResult.result[BB]->needObjs[itr.second]){
                            ischanged = true;
                            dataFlowResult.result[BB]->needObjs[itr.second]=itr.second;
                            //subNeedOobjStash.push_back(itr.second);
                        }
                    }
                }
//                while (subNeedOobjStash.size()){
//                    Value *value = subNeedOobjStash.pop_back_val();
//                    dataFlowResult.result[BB]->subBBneedObjs.erase(value);
//                }
                //dataFlowResult.result[BB]->subBBneedObjs.clear();
            }

            for(pred_iterator PI=pred_begin(BB),PE=pred_end(BB);PI!=PE;PI++){
                if(ischanged ||
                   (std::find(haveHandledBBSets.begin(),haveHandledBBSets.end(),*PI)==haveHandledBBSets.end())){
                    //errs()<<haveHandledBBSets.size()<<"haveHandleBBset\n";
                    worklist.push_back(*PI);
                }

            }

        }

        return &dataFlowResult;
    }


    bool DataFlow::mergeInAndUpdateOut(LoopInfo &LI,BasicBlock *basicBlock,  SmallVector<BlockResult*,4> &prevBlockResultsSet,
                                       BlockResult *blockResult) {
        bool isKilled = blockResult->killed;
        bool isLoopHead = false;
        if(LI.getLoopDepth(basicBlock)){
            isLoopHead = LI.getLoopFor(basicBlock)->getHeader() == basicBlock;
        }

        blockResult->inObjs.clear();

        //merge the prevBlock out pointer
        //errs()<<basicBlock->getName()<<" basicBlock\n";
        for(auto preBlockResult:prevBlockResultsSet){
            //errs()<<preBlock->getName()<<" prevBlock\n";
            for(auto outValue:preBlockResult->outObjs){
                if(outValue.second){
                    blockResult->inObjs[outValue.second]=outValue.second;
                }
            }
        }


        if(isLoopHead){
            for(auto needValue:dataFlowResult.loopResults[LI.getLoopFor(basicBlock)]->needObjs){
                if(needValue.second){
                    blockResult->inObjs[needValue.second]=needValue.second;
                }
            }
        }

        //if this block is killed, we do not need to update its out value;
        if(isKilled) return false;

        int addSize = 0;
        //merge this out value to the out
        for(auto itr:blockResult->inObjs){
            if(!blockResult->outObjs[itr.second]){
                blockResult->outObjs[itr.second]=itr.second;
                addSize+=1;
            }
        }

        if(addSize) return true;

        return false;
    }

    Value* DataFlow::findRequiredPointer(Value *pointer,BlockResult &blockResult) {
        Value *tempPointer= nullptr;
        if(isa<ConstantExpr>(pointer)) {
            if(GEPOperator *GEPO = dyn_cast<GEPOperator>(pointer)){
                tempPointer = GEPO->getPointerOperand();
                blockResult.GlobalorConstantValue[tempPointer]=tempPointer;
                return tempPointer;
            } else if(isa<ConstantPointerNull>(pointer)){
                return pointer;
            }else if(BitCastOperator *bco = dyn_cast<BitCastOperator>(pointer)){
                tempPointer = bco->getOperand(0);
                blockResult.GlobalorConstantValue[tempPointer]=tempPointer;
                return tempPointer;
            }

        } else if(GlobalValue *GV = dyn_cast<GlobalValue>(pointer)){
            blockResult.GlobalorConstantValue[GV]= GV;
            return GV;
        }
        return pointer;
    }

    void DataFlow::hanldInstructionToBuildUpNeedAndGen(BasicBlock::iterator &I,BlockResult &blockResult,std::vector<Value*> &noneRandomPointSet) {
        bool Killed = blockResult.killed;
        ShadowMap &needObjs = blockResult.needObjs;
        ShadowMap &genObjs = blockResult.genObjs;
        ShadowMap &outObjs = blockResult.outObjs;

#if 0
        if(isa<AllocaInst>(&*I))
            return;
        if(CallInst *ci=dyn_cast<CallInst>(&*I)){
            Value *srcFunction = ci->getCalledValue();
            if(ci->isInlineAsm()){
                return;
            }

            if(srcFunction->hasName() &&
               srcFunction->getName().startswith("llvm.") &&
               !srcFunction->getName().startswith("llvm.mem"))
                return;

            blockResult.killed=true;
            genObjs.clear();
            outObjs.clear();
        }
        //if this pointer is used by the loader and store
        if(pointerUsedbyStoreAndLoad.count(&*I)){
            genObjs[&*I]=&*I;
            outObjs[&*I]=&*I;
        }

        if(LoadInst *li=dyn_cast<LoadInst>(&*I)){
            Value *srcPointer = li->getOperand(0);
            if(!Killed){
                //we do not find this pointer in genObjs
                if(genObjs.find(srcPointer)==genObjs.end()){
                    needObjs[srcPointer]=srcPointer;
                }
            }else{
                outObjs[srcPointer]=srcPointer;
            }
        }

        if(StoreInst* si = dyn_cast<StoreInst>(&*I)){
            Value *destPointer = si->getPointerOperand();
            if(!Killed){
                //we do not find this pointer in genObjs
                if(genObjs.find(destPointer)==genObjs.end()){
                    needObjs[destPointer]=destPointer;
                }
            }else{
                outObjs[destPointer]=destPointer;
            }
        }
#else

        if(isa<AllocaInst>(&*I)){
            return;
        }

        if(CastInst *ci=dyn_cast<CastInst>(&*I)){
            if(ci->getType()->isPointerTy()){
                Value *srcPointer = findRequiredPointer(ci->getOperand(0),blockResult);
                if(!Killed){
                    //we do not find this pointer in our genobj
                    if(!blockResult.genObjs[srcPointer]){
                        if(!isa<IntToPtrInst>(&*I)){
                            blockResult.needObjs[srcPointer]=srcPointer;
                        }

                    }
                } else{
                    blockResult.outObjs[srcPointer] = srcPointer;
                }
                blockResult.genObjs[ci]=ci;
                blockResult.outObjs[ci]=ci;
            }
            return;
        }else if(GetElementPtrInst *gep=dyn_cast<GetElementPtrInst>(&*I)){
            Value *srcPointer = findRequiredPointer(gep->getPointerOperand(),blockResult);
            if(!Killed){
                if(!blockResult.genObjs[srcPointer]){
                    blockResult.needObjs[srcPointer]=srcPointer;
                }
            } else{
                blockResult.outObjs[srcPointer]=srcPointer;
            }
            blockResult.genObjs[gep]=gep;
            blockResult.outObjs[gep]=gep;
        }else if(LoadInst *li=dyn_cast<LoadInst>(&*I)){
            Value *srcPointer = findRequiredPointer(li->getOperand(0),blockResult);
            if(!Killed){
                //we do not find this pointer in our genobj
                if(!blockResult.genObjs[srcPointer]){
                    blockResult.needObjs[srcPointer]=srcPointer;
                }
            }else{
                blockResult.outObjs[srcPointer]=srcPointer;
            }
            if(li->getType()->isPointerTy()){
                blockResult.genObjs[li]=li;
                blockResult.outObjs[li]=li;
            }
        }else if(StoreInst* si = dyn_cast<StoreInst>(&*I)){
            Value *srcPointer = findRequiredPointer(si->getPointerOperand(),blockResult);
            if(!Killed){
                if(!blockResult.genObjs[srcPointer]){
                    blockResult.needObjs[srcPointer]=srcPointer;
                }
            }else{
                blockResult.outObjs[srcPointer]=srcPointer;
            }
            //blockResult.genObjs[srcPointer]=srcPointer;

        }else if(CallInst *ci=dyn_cast<CallInst>(&*I)){
            Value *srcFunction = ci->getCalledValue();
            if(ci->isInlineAsm()){
                if(ci->getType()->isPointerTy()){
                    blockResult.genObjs[ci]=ci;
                    blockResult.outObjs[ci]=ci;
                }
                return;
            }

            //some functions should be set as having no effects to the shadow flow for the purpose of debug.
            if(srcFunction->hasName() && isExcludeFunction(srcFunction))
                return;
            if(srcFunction->hasName() && srcFunction->getName().startswith("llvm."))
                return;
            Value *srcPointer = findRequiredPointer(srcFunction,blockResult);
            if(isRandomPoint(ci,srcFunction,noneRandomPointSet)){
                blockResult.killed=true;
                blockResult.genObjs.clear();
                blockResult.outObjs.clear();
            } else{
                if(!Killed){
                    if(!blockResult.genObjs[srcPointer]){
                        blockResult.needObjs[srcPointer]=srcPointer;
                    }
                }
                blockResult.genObjs[srcPointer]=srcPointer;
                blockResult.outObjs[srcPointer]=srcPointer;
            }
            //Pan-pathOram: we do not cache the translated address
//            if(ci->getType()->isPointerTy()){
//                    blockResult.genObjs[ci]=ci;
//                    blockResult.outObjs[ci]=ci;
//            }

        }else if(PHINode *phi=dyn_cast<PHINode>(&*I)){
            //TODO: panzhang take care of the phinode
            if(phi->getType()->isPointerTy()){
//                for(int i= 0,e=phi->getNumIncomingValues();i!=e;++i){
//                    Value *inComingValue = phi->getIncomingValue(i);
//                    if(isa<ConstantPointerNull>(inComingValue)) continue;
//                    blockResult.needObjs[inComingValue]=inComingValue;
//                }
                blockResult.genObjs[phi]=phi;
                blockResult.outObjs[phi]=phi;
            }
        } else if(SelectInst *si=dyn_cast<SelectInst>(&*I)){
            if(si->getType()->isPointerTy()){
                Value *truePointer = findRequiredPointer(si->getTrueValue(),blockResult);
                Value *falesPointer = findRequiredPointer(si->getFalseValue(),blockResult);
                if(!Killed){
                    if(!blockResult.genObjs[truePointer]){
                        blockResult.needObjs[truePointer]=truePointer;
                    }
                    if(!blockResult.genObjs[falesPointer]){
                        blockResult.needObjs[falesPointer]=falesPointer;
                    }
                }else{
                    blockResult.outObjs[falesPointer]=falesPointer;
                }
                blockResult.genObjs[si]=si;
                blockResult.outObjs[si]=si;
            }
        }else if(isa<CmpInst>(&*I)){

        }
#endif
    }

    void DataFlow::printResults(DataFlowResult *dataFlowResult, BasicBlock *basicBlock) {
        BlockResult* blockResult = dataFlowResult->result[basicBlock];

        errs()<<"\nblock is killed:"<<blockResult->killed<<" \n";
        errs()<<"1.-------------need obj:-------------\n";
        for(auto itr:blockResult->needObjs){
            if(itr.second){
                if(!dyn_cast<AllocaInst>(itr.second)){
                    itr.first->printAsOperand(errs());errs()<<" :";itr.second->print(errs());errs()<<" needOBJ\n";
                }

            }
        }
        basicBlock->print(errs());
        errs()<<"2.===Subneed obj:===\n";
        for(auto itr:blockResult->subBBneedObjs){
            if(itr.second){
                if(!dyn_cast<AllocaInst>(itr.second)){
                    itr.first->printAsOperand(errs());errs()<<" :";itr.second->printAsOperand(errs());errs()<<" SubOBJ\n";
                }

            }
        }
        errs()<<"3.======out shadow===\n";
        for(auto itr:blockResult->outShadow){
            if(itr.second){
                if(!dyn_cast<AllocaInst>(itr.second)){
                    itr.first->printAsOperand(errs());errs()<<" :\n";
//                    itr.second->print(errs());errs()<<" \n";
                    //itr.second->printAsOperand(errs());errs()<<" outShadow\n";
                }

            }
        }

//        errs()<<"===GV obj:===\n";
//        for(auto itr:blockResult->GlobalorConstantValue){
//            if(itr.second){
//                    itr.first->print(errs());errs()<<"GVValue\n";
//            }
//        }

        errs()<<"===in object:===\n";
        for(auto itr:blockResult->inObjs){
            if(itr.second){
                itr.first->print(errs());errs()<<"\n";
            }

        }
        errs()<<"===out object:===\n";
        for(auto itr:blockResult->outObjs){
            if(itr.second){
                itr.first->print(errs());errs()<<"\n";
            }

        }
    }


    LoopResult* DataFlow::calculateLoopInAndOut(LoopInfo &LI,Loop &loop) {
        //we have arrived the innerest loop;
//        if(loop.getSubLoops().size()==0)
        SmallVector<BasicBlock*,16> basicBlockList;
        unsigned currentDepth= loop.getLoopDepth();

        SmallVector<BasicBlock*, 16> LoopLatches;
        SmallVector<Value*,32> globalValutSet;
        loop.getLoopLatches(LoopLatches);

        for(auto blockItr:loop.blocks()){
            //get whole global values that exists in current loop
            if(LI.getLoopDepth(&*blockItr)==currentDepth){
                basicBlockList.push_back(&*blockItr);
            }
        }
        return nullptr;
    }

    LoopResult* DataFlow::initLoopResult(LoopInfo &LI, Loop *loop) {
        //loop->getLoopPreheader()->printAsOperand(errs());errs()<<"loop prehead\n";
        //loop->print(errs());errs()<<"loop info \n";
        SmallVector<BasicBlock*,4> exitBBs;
        loop->getExitBlocks(exitBBs);
//        for(auto bb:exitBBs){
//            bb->printAsOperand(errs());errs()<<" loop exitbb\n";
//        }


        for(auto blockItr:loop->blocks()){
            //get whole global values that exists in current loop
            for(auto valueItr:dataFlowResult.result[blockItr]->GlobalorConstantValue){
                if(valueItr.second){
                    dataFlowResult.loopResults[loop]->GlobalorConstantValue[valueItr.second]=valueItr.second;
                }
            }
            for(auto valueItr:dataFlowResult.result[blockItr]->needObjs){
                if(valueItr.second){
                    dataFlowResult.loopResults[loop]->needObjs[valueItr.second]=valueItr.second;
                }
            }
        }
        return dataFlowResult.loopResults[loop];
    }





}
