#include "Oram.hpp"
#include "ObliviousCPY.hpp"
#include "../Enclave.h"
#include "rtm-goto.h"
#include <sgx_trts.h>
#include <cstring>
#include <set>
#include "../debugConfig.h"

size_t calculateDepthByShadowPageNumber(size_t num){
    size_t temp,itr=0;
    do{
        itr++;
        temp = (1<<itr);     
    }while(temp < num);
    return itr+1;
}
static unsigned char getRandom_LessThan256(void){
    static unsigned char shuffle[32];
    static int i=0;
    i=i%32;
    if(i==0){
        sgx_read_rand(shuffle, sizeof(shuffle));
    }
    
    return shuffle[i++];
}
static unsigned short getRandom_LessThan16Byte(void){
    static unsigned short shuffle[32];
    static int i=0;
    i=i%32;
    if(i==0){
        sgx_read_rand((unsigned char *)shuffle, sizeof(shuffle));
    }
    
    return shuffle[i++];
}           

static inline void copyPageIntoSelectedYMMRegister(unsigned long src, int YMMNum){
    switch(YMMNum){
        case 0x0: copySrcToYMMX(0) break;
        case 0x1: copySrcToYMMX(1) break;
        case 0x2: copySrcToYMMX(2) break;
        case 0x3: copySrcToYMMX(3) break;
        case 0x4: copySrcToYMMX(4) break;
        case 0x5: copySrcToYMMX(5) break;
        case 0x6: copySrcToYMMX(6) break;
        case 0x7: copySrcToYMMX(7) break;
        case 0x8: copySrcToYMMX(8) break;
        case 0x9: copySrcToYMMX(9) break;
        case 0xa: copySrcToYMMX(10) break;
        case 0xb: copySrcToYMMX(11) break;
        case 0xc: copySrcToYMMX(12) break;
        case 0xd: copySrcToYMMX(13) break;
        case 0xe: copySrcToYMMX(14) break;
        case 0xf: copySrcToYMMX(15) break;
        default :printf("%s:YMMNum is greater than 0xf,0x%x\n",__func__,YMMNum); while(1){};        
    }
}

static inline void copyYMMRegisterToDest(unsigned long target_addr, int YMMNum){
    switch(YMMNum){         
        case 0x0: copyYMMXToTheMemeory(0) break;
        case 0x1: copyYMMXToTheMemeory(1) break;
        case 0x2: copyYMMXToTheMemeory(2) break;
        case 0x3: copyYMMXToTheMemeory(3) break;
        case 0x4: copyYMMXToTheMemeory(4) break;
        case 0x5: copyYMMXToTheMemeory(5) break;
        case 0x6: copyYMMXToTheMemeory(6) break;
        case 0x7: copyYMMXToTheMemeory(7) break;
        case 0x8: copyYMMXToTheMemeory(8) break;
        case 0x9: copyYMMXToTheMemeory(9) break;
        case 0xa: copyYMMXToTheMemeory(10) break;
        case 0xb: copyYMMXToTheMemeory(11) break;
        case 0xc: copyYMMXToTheMemeory(12) break;
        case 0xd: copyYMMXToTheMemeory(13) break;
        case 0xe: copyYMMXToTheMemeory(14) break;
        case 0xf: copyYMMXToTheMemeory(15) break;
        default :printf("%s:YMMNum is greater than 0xf,0x%x\n",__func__,YMMNum); while(1){};
    }
}             

PathORAM::PathORAM(size_t PathORAMReservedArea_start,size_t originalAddr,
                    size_t pageNumber,size_t blockSize,int startIndex,int stashSize):BlockSize(blockSize){
    
    maxRealBlocksNum= Z; // Z: Maximum number of real blocks per bucket, 
	reservedDummyNum= S; // S: Number of slots reserved for dummies per bucket
	BlocksInABucket = BLOCKSINBUCKET;  // the number of blocks in a bucket = S+Z
    currentStashBoundry=MINISTASHSIZE;
    G =0;
    recordGroupNum=0;
    RecentAccessROR = 0;
    shuffleStashtimes = 0;
    obliviousWriteBucketWriteBuckNum=0;
    getAllValidPageMACTimes=0;
    currentStashPtr = 0;
    recordStash=0xffff;
    round=0;
    isInEvictPath=false;
    print_count=0;

    StashSize = stashSize;
    Depth = calculateDepthByShadowPageNumber(pageNumber);
    ReservedArea = (char *)PathORAMReservedArea_start;
    // printf("pageNumber 0x%x, Oram depth is %d, blocksInABucket %d, blockSize 0x%lx \n",pageNumber,Depth,GetNumOfBlockInABucket(),SHADOWPAGESIZE);
    // printf("PathORAMReservedArea_start %lx\n",PathORAMReservedArea_start);
    bucketNumber = (uint32_t)(1 << Depth) - 1;
    bucketMetaData = new Bucket[bucketNumber];
    position = new int[pageNumber];
    StartIndex=startIndex;

    // printf("bucketMetaData: %lx,bucketNumber:%d\n",bucketMetaData,bucketNumber);
    // printf("position:%lx\n",position);

    stash = new StashMetadata[STASHSIZE];

    size_t stashStartAddress = PathORAMReservedArea_start;
    //init stash
    for(int itr=0;itr<StashSize;itr++){
        stash[itr].index=0;
        // stash[itr].leaf=0;
        stash[itr].address=(char *)(stashStartAddress + SHADOWPAGESIZE*itr);
    }

    int bucketIndex = 1;
    Bucket * bucketTemp= NULL;

    size_t bucketStartAddress = PathORAMReservedArea_start + (SHADOWPAGESIZE * StashSize);
    
    bucketMetaData[0].nodeStartAddress= (char *)bucketStartAddress;
    bucketMetaData[0].parent=NULL;
    bucketMetaData[0].count = 0;
    bucketMetaData[0].valid = 0;
    for(int itr=0;itr<BLOCKSINBUCKET;itr++){
        // bucketTemp->blocks[itr].address=0x0;
        bucketMetaData[0].blocks[itr].leaf = 0xfff;
        bucketMetaData[0].blocks[itr].offset = (unsigned short)itr;
        bucketMetaData[0].blocks[itr].index = 0;
        // printf("%d,%d\n",bucketTemp->blocks[itr].offset,bucketTemp->blocks[itr].leaf);
    }
    // printf("depth:1: StartAddress:%lx,%lx\n",bucketStartAddress,GetNumOfBlockInABucket() * SHADOWPAGESIZE);
    bucketStartAddress+= GetNumOfBlockInABucket() * SHADOWPAGESIZE;

    int curDepth=2;
    //init the bucket
    size_t lastRecord=0;
    for(;curDepth<=Depth;curDepth++){
        int prevLayerStartIndex = (1<<(curDepth-2))-1;
        
        // printf("prevLayerStartIndex:%d\n",prevLayerStartIndex);
        // printf("depth:%d: StartAddress:%lx\n",curDepth,bucketStartAddress);
        lastRecord=bucketStartAddress;
        for(int curLeaf=0;curLeaf<(1<<(curDepth-1));curLeaf++,bucketIndex++){
            
            bucketTemp = &bucketMetaData[bucketIndex];

            bucketTemp->nodeStartAddress=(char *)bucketStartAddress;
            
            int leafAtDepth = curLeaf>>1;

            bucketTemp->parent = &bucketMetaData[prevLayerStartIndex + leafAtDepth];
            // printf("bucketIndex:%d ->parent :%d\n",bucketIndex,prevLayerStartIndex + leafAtDepth);
            bucketStartAddress+= GetNumOfBlockInABucket() * SHADOWPAGESIZE;
            // printf("nodeStartAddress %lx\n",bucketTemp->nodeStartAddress);

            bucketTemp->count = 0;
            bucketTemp->valid = 0;
            for(int itr=0;itr<BLOCKSINBUCKET;itr++){
                // bucketTemp->blocks[itr].address=0x0;
                bucketTemp->blocks[itr].leaf = 0xfff;
                bucketTemp->blocks[itr].offset = (char)itr;
                bucketTemp->blocks[itr].index = 0;
                // printf("%d,%d\n",bucketTemp->blocks[itr].offset,bucketTemp->blocks[itr].leaf);
            }
        }
        // printf(" size:%lx,%d, endAddress:%lx\n",bucketStartAddress-lastRecord,(bucketStartAddress-lastRecord)/(SHADOWPAGESIZE*GetNumOfBlockInABucket() ),bucketStartAddress);   
    }

    // printf("===============================\n");

    //copy the date to the bucket
    bucketIndex = GetNodeOnPath(0,GetDepth());
    for(int itr=0;itr<pageNumber;itr++,bucketIndex++){   
        bucketTemp = &bucketMetaData[bucketIndex];
        unsigned char a = getRandom_LessThan256() % GetNumOfBlockInABucket();

        char *dest = bucketTemp->nodeStartAddress + a*SHADOWPAGESIZE;
        char *src = (char *)originalAddr + itr*SHADOWPAGESIZE;
        
        memcpy(dest,src,SHADOWPAGESIZE);

        int magic = *(int *)dest;
        position[itr]=itr;
        bucketTemp->blocks[a].index=startIndex+itr;
    }

    PATHReadingGroup = new size_t[Depth];
    StashReadingGroup = new size_t[STASHSIZE];

    helperarrayForStashShuffle= new size_t[STASH_SHUFFLE_GROUP_NUM];
    shuffleGroup = new size_t[STASH_SHUFFLE_GROUP_NUM];
    for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
        shuffleGroup[i]=i*SHADOWPAGESIZE*2;
        helperarrayForStashShuffle[i]=i;
    }

    helperArrayForWriteBuck = new size_t[BLOCKSINBUCKET];
    for(int i=0;i<BLOCKSINBUCKET;i++){
        helperArrayForWriteBuck[i]=i;
    }

    for(int i=1;i<STASHSIZE;i++){
        StashReadingGroup[i]=(size_t)ReservedArea + i*SHADOWPAGESIZE;
    }
    leafStartIndex = GetNodeOnPath(0,GetDepth());
    tempBucketContainer = (struct Bucket **)malloc(sizeof(struct Bucket *)*Depth);
    tempBlockContainer = (struct Block  **)malloc(sizeof(struct Block  *)*BLOCKSINBUCKET);
    realPageNumber = pageNumber;
}

int PathORAM::GetNodeOnPath(int leaf, int targetDepth){
    int leafAtDepth = leaf >> (Depth - targetDepth);
    int node = (1<<(targetDepth - 1)) -1 +leafAtDepth;
    return node;
}
Bucket * PathORAM::GetLeafBucket(int leaf){
    return &bucketMetaData[leafStartIndex+leaf];
}

Bucket * PathORAM::GetBucketOnPath(int leaf,int targetDepth){
    
    return &bucketMetaData[GetNodeOnPath(leaf,targetDepth)];
}

void PathORAM::getBucketOfAPath(int leaf,std::vector<Bucket*> &path){
    Bucket * bucket = GetBucketOnPath(leaf,GetDepth());
    do{
        path.push_back(bucket);
        bucket = bucket->parent;
    }while(bucket);
}

bool PathORAM::ReadPath(int leaf,int blockIndex,size_t targetAddress){
    int offset;
    size_t srcAddress;
    Bucket *bucket = GetLeafBucket(leaf);
    int itr=0;
    bool isReal=false;
    int realBlockIndex = 0;
    
    do{
        // printf("=== bucket start === itr %d ==== valid:%d =====,\n",Depth-itr, bucket->valid);
        int curBlockOffset = GetBlockOffset(bucket,blockIndex,isReal);
        if(isReal){
            // printf("find real one!!!!\n");
            realBlockIndex = itr;
            isReal=false;
        }
        struct Block &chosenBlock = bucket->blocks[curBlockOffset];
        //Invalidate of the slot in this bucket
        bucket->valid |= (1<<chosenBlock.offset); //from 0 -> 1
        
        //import the block's address to the sequence.
        PATHReadingGroup[itr] = (size_t)bucket->nodeStartAddress + chosenBlock.offset*SHADOWPAGESIZE;
        
        {
            //exchange the blocks in a bucket
            struct Block &exchangeBlock = bucket->blocks[BlocksInABucket - bucket->count - 1];
            chosenBlock.offset = exchangeBlock.offset;
            chosenBlock.leaf = exchangeBlock.leaf;
            chosenBlock.index = exchangeBlock.index;
        }
        
        //increase the account
        bucket->count +=1;
        bucket = bucket->parent;  
        itr++;
    }while(bucket);

    //copy the data of the block to the targetAddress
    obliviousCPY_HF(PATHReadingGroup,itr,realBlockIndex,targetAddress);
    return true;
}

bool PathORAM::EvictPath(){
    //select a path, and evict blocks as many as possible to it.
    bool state=true;
    int pathIndex = G % (1<<(GetDepth()-1));
    G++;
    Bucket * bucket = NULL;
    int i=1;
    //1. read the whole buckets on this path to the stash
    for(;i<=GetDepth();i++){
        bucket = GetBucketOnPath(pathIndex,i);
        if(!ReadBucket(bucket)) state = false;
    }

    //2. write back buckets to the path
    bucket= GetLeafBucket(pathIndex);
    int min,max;
    int itr=0;
    do{
        min = (pathIndex >> itr)<<itr;
        max = ((pathIndex >> itr) + 1)<<itr;
        // isInEvictPath=true;
        if(!WriteBucket(bucket,min,max)) state = false;
        // isInEvictPath=false;
        bucket = bucket->parent;
        itr++;
    }while(bucket);
    
    return state;
}

int PathORAM::EarlyReshuffle(int leafIndex){ 
    int state=SUCCESS;
    Bucket *bucket = GetLeafBucket(leafIndex);
    int min,max;
    // iterator from the root to the leaf
    int leaf = leafIndex;
    int itr= GetDepth()-1;
    
    for(;itr>=0;itr--){
        tempBucketContainer[itr] = bucket;
        bucket = bucket->parent;
    }
    for(itr=1;itr<=GetDepth();itr++){

        if(tempBucketContainer[itr-1]->count >= S){
            int shift = GetDepth() - itr;
            min = (leaf >> shift)<<shift;
            max = ((leaf >> shift) + 1)<<shift;
            if(!ReadBucket(tempBucketContainer[itr-1])){
                state = ReadBucketFailed;
                goto exitOut;
            } 
            if(!WriteBucket(tempBucketContainer[itr-1],min,max)){
                
                state = WriteBucketFailed;
                goto exitOut;
            } 
        }
    }

exitOut:
    return state;
}

int PathORAM::Access(int blockIndex, int evictedBlockIndex, size_t targetAddress,bool needDoSwap){
    //record the new evicted pageindex
    recordNewEvictPage(evictedBlockIndex);

    //2. get a spare stash
    int spareIndex;
    size_t spareStashAddress=0;
    spareIndex = getASparePageInStash(spareStashAddress);

    //0. check whether the block is inside of the stash
    struct StashMetadata * srcStashSlot=NULL;
    // size_t srcAddress = 0;
    int srcIndex=0;
    for(int itr=0;itr<currentStashBoundry;itr++){
        if(stash[itr].index==(blockIndex)){
            // srcAddress=stash[itr].address;
            srcIndex = itr;
            srcStashSlot=&stash[itr];
            // printf("srcIndex:%d itr:%d\n",srcIndex,itr);
            // break;
        }
        // stashPageAddress += SHADOWPAGESIZE;
    }

    if(srcStashSlot){
        SWAPCachePageOutTargetIn(targetAddress,srcIndex,spareIndex,needDoSwap);
        srcStashSlot->index=0;
        stash[spareIndex].index=evictedBlockIndex;
        return SUCCESS;
    }

    //1. position Map lookup
    unsigned short a = getRandom_LessThan16Byte() % (1 << (GetDepth()-1));
    int pathIndex = position[blockIndex-1];                                                                                     
    position[blockIndex-1] = a;

    //2. swap the cache page out
    if(needDoSwap){
        for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){ 
            cpySrcToYMM_GROUP(targetAddress+pageOffset);
            copyYMMXToTheMemeory_GROUP(spareStashAddress+pageOffset);
        }
        stash[spareIndex].index=evictedBlockIndex;
    }

    //3. Read the path 
    if(!ReadPath(pathIndex,blockIndex,targetAddress)){
        return READPathFailed;
    }

    round = (round + 1)%A;
    if(round==0){
        // printf("EvictPath\n");
        EvictPath();
    }


    if(int state = EarlyReshuffle(pathIndex)){
        return state;
    }   
    return 0;
}

int PathORAM::GetBlockOffset(Bucket *bucket,int BlockIndex,bool &isReal){
    int offset = -1;
    
    for(int i=0;i<(BlocksInABucket - bucket->count);i++){
        Block &block = bucket->blocks[i]; 
        
        //record the first dummy block as the target block
        if(block.index==0){
            if(offset<0){
                offset=i;
            }
        }else if(block.index==BlockIndex){
            isReal = true;
            offset=i;
            break;
        }
    }
    return offset;
}

bool PathORAM::ReadBucket(Bucket *bucket){
    int z = 0; //track # of remaining real blocks
    int blocksTempScanSequence[BLOCKSINBUCKET];

    int itr=0,i=0,j=BlocksInABucket-bucket->count-1;
    for(;itr<(BlocksInABucket - bucket->count);itr++){
        Block &block = bucket->blocks[itr];

        if(block.index==0x0){
            blocksTempScanSequence[j]=itr;
            j--;
        }else{
            blocksTempScanSequence[i]=itr;
            i++;
        }
    }

    //Read the chosen blocks to the stash
    for(itr=0;itr<Z;itr++){   
        //1. get a spare stash space
        size_t sparePageAddressInStash;
        size_t stashIndex = getASparePageInStash(sparePageAddressInStash);
   
        size_t srcPageSpace;
        Block &block = bucket->blocks[blocksTempScanSequence[itr]];
        srcPageSpace = (size_t)bucket->nodeStartAddress + block.offset * SHADOWPAGESIZE;
        if(recordStash==0xffff){
            recordStash = (int)stashIndex;
        }

        //2. copy the a block to the stash
        for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){
            cpySrcToYMM_GROUP((srcPageSpace+pageOffset));  
            copyYMMXToTheMemeory_GROUP((sparePageAddressInStash+pageOffset));
        }

        //set stash
        stash[stashIndex].index = block.index;      
    }
    bucket->valid = 0;
    return true;

}
bool PathORAM::WriteBucket(Bucket *bucket,int min,int max){
    //look the stash and find up to Z blocks,[minleaf,maxleaf]
    int z=0;
    //clear Bucket
    for(int itr=0;itr<BLOCKSINBUCKET;itr++){
        struct Block &block = bucket->blocks[itr];
        block.offset=itr;
        block.index=0;
    }
    int chosenStashBlocks[Z];
    int dummy_begin=0,dummy_end=0;

    int randomStashIndex = (getRandom_LessThan16Byte() % (currentStashBoundry));
    size_t stashAddress=(size_t)ReservedArea + randomStashIndex*SHADOWPAGESIZE;
    
    for(int itr=0;itr<currentStashBoundry && z<Z;itr++){
        struct StashMetadata &stashMetaData = stash[randomStashIndex];
        int index = position[(stashMetaData.index)-1];
        bool isRecentEvicted=false;
        //check whether this page is evicted recently
        for(int ritr=0;ritr<RECORDRECENTNUM;ritr++){
            if((stashMetaData.index)==RecentEvict[ritr]){
                isRecentEvicted=true;
                break;
            }
        }
        if((stashMetaData.index)==0x0){
            if(dummy_end<Z){
                chosenStashBlocks[dummy_end]=(size_t)randomStashIndex;
                dummy_end++;
            }
        }else if((index>=min && index < max) && !isRecentEvicted){
            chosenStashBlocks[dummy_begin]=(size_t)randomStashIndex;
            if(dummy_begin==dummy_end){
                dummy_end++;
            }
            dummy_begin++;
            z++;
        }
        randomStashIndex=(randomStashIndex+1)%currentStashBoundry;
    }
    
    obliviousWriteBucket(chosenStashBlocks,dummy_end,dummy_begin,bucket,BLOCKSINBUCKET);

    //reset the bucket state
    bucket->count = 0;
    bucket->valid = 0;
    return true;
}

#define DebugStash 0
size_t PathORAM::getASparePageInStash(size_t &targetAddress){
   targetAddress = 0;
#if DebugStash
   int leftindex=0;
#endif
   for(int itr=0;itr<currentStashBoundry;itr++){
        if(currentStashPtr==recordStash){
            shuffleStash();
            itr=0;
            currentStashPtr=0;
            recordStash=0xffff;
        }else{
            currentStashPtr = currentStashPtr%currentStashBoundry;
        }
        struct StashMetadata & stashMeta  =  stash[currentStashPtr];
        currentStashPtr+=1;
        if(stashMeta.index==0x0){
            targetAddress = (size_t)stashMeta.address;
#if DebugStash
            leftindex++;
#else 
            break;
#endif
        }
   }

   if(targetAddress==0){
        //the spare is not enough, so we need to extend the stashboundry
       targetAddress= (size_t)ReservedArea + currentStashBoundry*SHADOWPAGESIZE;
       currentStashBoundry++;
       currentStashPtr=currentStashBoundry;
       return currentStashPtr-1;
   }

   for(;(currentStashPtr < currentStashBoundry) && currentStashBoundry>32 && stash[currentStashBoundry-1].index==0;){
        currentStashBoundry--;
   }

   //the left code is used to debug the stash
#if DebugStash
//    printf("left index %d\n",leftindex);
//    if(targetAddress==0){
//      for(int itr=0;itr<StashSize;itr++){
// 		size_t stashAddres = (size_t)ReservedArea + itr*SHADOWPAGESIZE;
// 		if((itr%8) == 0){
// 			printf("\n");
// 		}
// 		printf("\t %d=%d",itr,*(int *)stashAddres);	
//     }
   

//    }
//     //check whether the block is inside
//     for(int itr=0;itr<realPageNumber;itr++){
//         int num=0;
//         // if(searchBlockInStash(itr+1)!=0xffff){
//         //     num=1;
//         // }
//         num+=stasticIndexBlock(itr+1);
//         if(num!=1){
//             printf("find a block error%d,itr:%d\n",num,itr+1);
//         }

//     }
#endif
   return (currentStashPtr-1);
}

int PathORAM::quickCopyAShadowPage(size_t destAddr,size_t srcAddr){
    
    unsigned status = _XABORT_EXPLICIT;
    int abortNum = 0;

    static int itr=0;
    for(;itr<SPLITNUM;itr++){
        int offset = itr*(SHADOWPAGESIZE/SPLITNUM);
    repeat:
        XBEGIN(abort);
            for(int i=0;i<SHADOWPAGESIZE/SPLITNUM;i+=8){
                *(unsigned long *)(destAddr+offset+i) = *(unsigned long *)(srcAddr+offset+i);
            }
        XEND();
        continue;

        XFAIL_STATUS(abort, status);
            if(status&2){
                goto repeat;
            }
            return offset;
    }
    itr=0;
    return SHADOWPAGESIZE;
}

int PathORAM::obliviousCPY_HF(size_t *Group,int groupNum,int srcIndex,size_t destAddress){
    for(size_t pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){
        for(int i=0;i<groupNum;i++){
            if(i==srcIndex){
                cpySrcToYMM_GROUP((Group[i]+pageOffset));
            }else{
                intendToRead((Group[i]+pageOffset));
            }   
        }
        copyYMMXToTheMemeory_GROUP((destAddress+pageOffset));
    }
    return 0;
}

int  PathORAM::shuffleAGroupOfpages(size_t *Group,int groupNum){
    int median;
    size_t arrayForshuffleAGroupOfpages[STASH_SHUFFLE_GROUP_NUM];
    if(recordGroupNum!=groupNum){
        for(int i=0;i<groupNum;i++){
            arrayForshuffleAGroupOfpages[i]=i;
        }
        for(int i=0;i<(groupNum);i++){
            int value = i + getRandom_LessThan256() % (groupNum - i);
            if(value ==0) continue;
            median = arrayForshuffleAGroupOfpages[i];
            arrayForshuffleAGroupOfpages[i] = arrayForshuffleAGroupOfpages[value];
            arrayForshuffleAGroupOfpages[value] = median;
        }
        
    } 
    for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=32){
        //copy src->register
        size_t srcAddress;
        for(int i=0;i<groupNum;i++){
            copyPageIntoSelectedYMMRegister(Group[i]+pageOffset,i);
        }
        //copy register->dest
        for(int i=0;i<groupNum;i++){
            copyYMMRegisterToDest(Group[arrayForshuffleAGroupOfpages[i]]+pageOffset,i);
        }
    }
    return 0;
}


int PathORAM::SWAPCachePageOutTargetIn(size_t targetCachePageAddress,int srcIndex,int sparePageIndex,bool needDoSwap){
    if(needDoSwap){
        size_t destSpareAddr= (size_t)ReservedArea + sparePageIndex*SHADOWPAGESIZE;
        for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){
            cpySrcToYMM_GROUP((targetCachePageAddress+pageOffset));
            copyYMMXToTheMemeory_GROUP(destSpareAddr + pageOffset);
        }
    }

    for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){
        size_t srcAddr= (size_t)ReservedArea + pageOffset;
        for(int i=0;i<currentStashBoundry;i++){
            if(i==srcIndex){
                cpySrcToYMM_GROUP((srcAddr));
            }else{
                intendToRead((srcAddr));
            }
            srcAddr+=SHADOWPAGESIZE;
        }
        copyYMMXToTheMemeory_GROUP(targetCachePageAddress+pageOffset);
    }
    return 0;
}


//functions that are used to stastic the state
void PathORAM::coutStashState(){
    static int i=0;
    int index=0;
    for(int itr=0;itr<currentStashBoundry;itr++){
		size_t stashAddres = (size_t)ReservedArea + itr*SHADOWPAGESIZE;
        struct StashMetadata &stashTemp=stash[itr];
		if((itr%8) == 0){
			printf("\n");
		}
		printf("\t %d=%d,%d",itr,stashTemp.index,*(int *)stashTemp.address);	
        if(stashTemp.index){
            index++;
        }
    }
    if(index>i){
        i=index;
        printf("a new value:%d\n",index);
    }
}

int PathORAM::stasticIndexBlock(int blockIndex){
    int num = 0;
    size_t addr = (size_t)ReservedArea - CACHENUM*SHADOWPAGESIZE;
    int itr=0;

    for(;itr<((1<<(Depth)))*GetNumOfBlockInABucket() + StashSize + CACHENUM;itr++){
        if(*(int*)addr==blockIndex){
            num++;
        }
        addr +=SHADOWPAGESIZE;
    }
    return num;
}

int PathORAM::findBlockLeafIndex(int blockIndex){
    int leafIndex = 0xffff;
    size_t start_address;
    for(int i=0;i<(1 << (GetDepth()-1));i++){
        Bucket *bucket = GetLeafBucket(i);
        int itr = GetDepth();
        do{
            start_address = (size_t)bucket->nodeStartAddress;
            for(int pageitr=0;pageitr<BLOCKSINBUCKET;pageitr++){
                if(*(int *)start_address==blockIndex){
                    printf("find blockIndex%d,in leaf:%d,depth:%d\n",blockIndex,i,itr);
                    return i;
                }
                start_address+=SHADOWPAGESIZE;
            }
            bucket=bucket->parent;
            itr--;
        }while(bucket);
    }

    
    return leafIndex;
}

int PathORAM::searchBlockInStash(int blockIndex){
    for(int i=0;i<StashSize;i++){
        // if(*(int*)start_address==blockIndex){
        if(stash[i].index==blockIndex){
            return i;
        }
        // start_address+=SHADOWPAGESIZE;
    }
    return 0xffff;
}

void PathORAM::recordNewEvictPage(int pageIndex){
    if(pageIndex==0) return;
    RecentEvict[RecentAccessROR]=pageIndex;
    RecentAccessROR = (RecentAccessROR+1) % RECORDRECENTNUM;
    return;   
}    

void PathORAM::shuffleStash(){
    int randomI =(getRandom_LessThan256()%(currentStashBoundry-STASH_SHUFFLE_GROUP_NUM*2+1));
    size_t startAddress = (size_t)ReservedArea + SHADOWPAGESIZE * randomI;
    int tempIndexRecord[STASH_SHUFFLE_GROUP_NUM];
    
    if(shuffleStashtimes==0){
        for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
            helperarrayForStashShuffle[i]=i;
        }
        for(int i=0;i<(STASH_SHUFFLE_GROUP_NUM);i++){
            int value = i + getRandom_LessThan256() % (STASH_SHUFFLE_GROUP_NUM - i);
            if(value ==0) continue;
            int median = helperarrayForStashShuffle[i];
            helperarrayForStashShuffle[i] = helperarrayForStashShuffle[value];
            helperarrayForStashShuffle[value] = median;
        }
        shuffleStashtimes = (shuffleStashtimes++)%16;
    } 
    for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=32){
        //copy src->register
        size_t srcAddress;
        for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
            copyPageIntoSelectedYMMRegister(startAddress+ shuffleGroup[i]+pageOffset,i);
        }
        //copy register->dest
        for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
            copyYMMRegisterToDest(startAddress + shuffleGroup[helperarrayForStashShuffle[i]]+pageOffset,i);
        }
    }   

    for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
        tempIndexRecord[i]= stash[randomI+i*2].index;
    }
    for(int i=0;i<STASH_SHUFFLE_GROUP_NUM;i++){
        stash[randomI+helperarrayForStashShuffle[i]*2].index=tempIndexRecord[i];
    }
    return ;

}


int PathORAM::obliviousWriteBucket(int *srcBlock,int srcNum,int realNum,Bucket *bucket,int bucketNum){
    //1. randomly chose position for real bucket
    if(0==obliviousWriteBucketWriteBuckNum){
        for(int i=0;i<(BLOCKSINBUCKET);i++){
            helperArrayForWriteBuck[i]=i;
        }
    }
    obliviousWriteBucketWriteBuckNum = (obliviousWriteBucketWriteBuckNum+1)%32;

    size_t destBucketStartAddress =(size_t)bucket->nodeStartAddress;

    for(int itr=0;itr<srcNum;itr++){
        size_t srcBlockStartAddress = (size_t)stash[srcBlock[itr]].address;
        size_t targetOffset = helperArrayForWriteBuck[itr]*SHADOWPAGESIZE;
        if(itr<realNum){
            // printf("itr,%d,%d, %lx\n",itr,helperArrayForWriteBuck[itr],srcBlock[itr]);
            for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){ 
            //1.copy the srcBlock to YMMs
                cpySrcToYMM_GROUP((srcBlockStartAddress + pageOffset));
            //2. copy the YMMs to the target
                for(int bucketItr=0;bucketItr<BLOCKSINBUCKET*SHADOWPAGESIZE;bucketItr+=SHADOWPAGESIZE){
                    if(bucketItr==targetOffset){
                        copyYMMXToTheMemeory_GROUP(destBucketStartAddress+bucketItr+pageOffset);
                    }else{
                        intendToAccessRW(destBucketStartAddress+bucketItr);
                    }
                }
            }
        }else{
            for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){
                intendToRead(srcBlockStartAddress);
                for(int bucketItr=0;bucketItr<BLOCKSINBUCKET*SHADOWPAGESIZE;bucketItr+=SHADOWPAGESIZE){
                    // if(bucketItr==targetOffset){
                        intendToAccessRW(destBucketStartAddress + bucketItr);
                    // }else{
                    //     intendToAccessSrcAndWriteZeroToDest(srcBlockStartAddress,destBucketStartAddress+bucketItr);
                    // }
                }
            }
        }
        
    }

    //set bucket block Index
    for(int itr=0;itr<realNum;itr++){
        bucket->blocks[helperArrayForWriteBuck[itr]].index=stash[srcBlock[itr]].index;
        stash[srcBlock[itr]].index=0;
    }
    
    return 0;

}

void PathORAM::writeCashBack(size_t cacheStartAddress,int pageNum,int evictNum,int *cacheIndex,int cacheStartIndex){
    
    size_t currentSwapCacheAddress = cacheStartAddress;
    for(int i=cacheStartIndex;i<pageNum;i++){
        if(!cacheIndex[i]){
            currentSwapCacheAddress+=SHADOWPAGESIZE*CACHESPARENUM;
            continue;
        }
        recordNewEvictPage(cacheIndex[i]);
        //1. get a spare stash
        int spareIndex;
        size_t spareStashAddress=0;
        spareIndex = getASparePageInStash(spareStashAddress);

        //2. write the cache page back to the stash space
        for(int pageOffset=0;pageOffset!=(SHADOWPAGESIZE);pageOffset+=0x200){ 
            cpySrcToYMM_GROUP(currentSwapCacheAddress+pageOffset);
            copyYMMXToTheMemeory_GROUP(spareStashAddress+pageOffset);
        }
        //3. continue the swap
        stash[spareIndex].index=cacheIndex[i];
        cacheIndex[i]=0;
        currentSwapCacheAddress+=SHADOWPAGESIZE*CACHESPARENUM;
    }

    //then we should evict some pages back to the Oram tree
    for(int itr_1=0;itr_1<evictNum;itr_1++){

        bool state=true;
        int pathIndex =  getRandom_LessThan16Byte() % (1<<(GetDepth()-1));

        Bucket * bucket = NULL;
        int i=1;
        //1. read the whole buckets on this path to the stash
      
        for(;i<=GetDepth();i++){
            bucket = GetBucketOnPath(pathIndex,i);
            if(!ReadBucket(bucket)) state = false;
        }

        //2. write back buckets to the path
        bucket= GetLeafBucket(pathIndex);
        int min,max;
        int itr=0;
        do{
            min = (pathIndex >> itr)<<itr;
            max = ((pathIndex >> itr) + 1)<<itr;
            // isInEvictPath=true;
            // printf("depth:%d\n,min:%d,max%d\n",GetDepth()-itr,min,max);
            if(!WriteBucket(bucket,min,max)) state = false;
            // isInEvictPath=false;
            bucket = bucket->parent;
            itr++;
        }while(bucket);
    }

}

#define INDEXOFFSET 0
int PathORAM::checkInStashOrOramTree(){
    int targetIndex;
    for(int indexItr=0;indexItr < realPageNumber;indexItr++){
        targetIndex = indexItr + StartIndex;

        int count=0;
        //check whether in cache
        for(int itr=0;itr<CacheNumber;itr++){
            if(CacheIndex[itr]==targetIndex){
                size_t targetAddr = CacheStart + itr*SHADOWPAGESIZE;
                if(*(int *)targetAddr != targetIndex+INDEXOFFSET){
                    printf("checkInStashOrOramTree target  content and index is not corrent in Cache\n");
                    printf("content:%lx,index:%lx,itr:%lx\n",*(int *)targetAddr,CacheIndex[itr],itr);
                    while(1){}
                }
                count++;
            }
        }
        //check whether in stash
        for(int itr=0;itr<currentStashBoundry;itr++){
            struct StashMetadata &stashTemp=stash[itr];
            if(stashTemp.index==targetIndex){
                //check the content
                if(*(int *)stashTemp.address!=stashTemp.index+INDEXOFFSET){
                    printf("checkInStashOrOramTree target  content and index is not corrent in Stash\n");
                    printf("content:%d,index:%lx\n",*(int *)stashTemp.address,stashTemp.index);
                    while(1){}
                }
                count++;
            }
        }
        //check whether in OramTree
        for(int itr=0;itr<bucketNumber;itr++){
            struct Bucket &bucket=bucketMetaData[itr];
            for(int blockItr=0;blockItr<(BLOCKSINBUCKET-bucket.count);blockItr++){
                struct Block &block=bucket.blocks[blockItr];
                if(block.index==targetIndex){
                    size_t block_address = (size_t)bucket.nodeStartAddress + block.offset*SHADOWPAGESIZE;
                    if(*(int *)block_address!=block.index+INDEXOFFSET){
                        printf("checkInStashOrOramTreetarget  content and index is not corrent in OramTree\n");
                        printf("content:%d,index:%lx\n",*(int *)block_address,block.index);
                        printf("%lx,%lx\n",(size_t)bucket.nodeStartAddress,block.offset);
                        while(1){}
                    }
                    count++;
                }
            }
        }

        if(count>1){
            printf("the index:%d is more than %d\n",targetIndex,count);

            for(int itr=0;itr<CacheNumber;itr++){
                size_t targetAddr = CacheStart + itr*SHADOWPAGESIZE;
                if(CacheIndex[itr]==targetIndex){
                    printf("find in cache\n");
                    printf("content:%d,index:%d\n",*(int *)targetAddr,CacheIndex[itr]);
                }
            }

            for(int itr=0;itr<currentStashBoundry;itr++){
                struct StashMetadata &stashTemp=stash[itr];
                if(stashTemp.index==targetIndex){
                    //check the content
                    printf("find in Stash\n");
                    printf("content:%d,index:%d\n",*(int *)stashTemp.address,stashTemp.index);
                }
            }   

            for(int itr=0;itr<bucketNumber;itr++){
                struct Bucket &bucket=bucketMetaData[itr];
                for(int blockItr=0;blockItr<(BLOCKSINBUCKET-bucket.count);blockItr++){
                    struct Block &block=bucket.blocks[blockItr];
                    if(block.index==targetIndex){
                        size_t block_address = (size_t)bucket.nodeStartAddress + block.offset*SHADOWPAGESIZE;
                        printf("find in OramTree:bucketNumber:%d, block.itr:%d,  offset:%d\n",itr,blockItr,block.offset);
                        printf("content:%d,index:%d\n",*(int *)block_address,block.index);
                    }
                }
            }

            while(1){}
        }
    }
    
    return 0;
}

int PathORAM::checkWhetherInTheRightORAMTree(){
    int targetIndex;
    for(int indexItr=0;indexItr < realPageNumber;indexItr++){
        targetIndex = indexItr + StartIndex;
        int count =0;
        //check whether in cache
        for(int itr=0;itr<CacheNumber;itr++){
            if(CacheIndex[itr]==targetIndex){
                size_t targetAddr = CacheStart + itr*SHADOWPAGESIZE;
                // if(*(int *)targetAddr != targetIndex){
                //     printf("target  content and index is not corrent in Cache\n");
                //     printf("content:%d,index:%d\n",*(int *)targetAddr,CacheIndex[itr]);
                //     while(1){}
                // }
                count++;
            }
        }
        if(count == 1) continue;
        
        //check whether in stash
        for(int itr=0;itr<currentStashBoundry;itr++){
            struct StashMetadata &stashTemp=stash[itr];
            if(stashTemp.index==targetIndex){
                //check the content
                if(*(int *)stashTemp.address!=stashTemp.index){
                    printf("target  content and index is not corrent in Stash\n");
                    printf("stash itr:%d,index:%d,content:%d\n",itr,stashTemp.index,*(int *)stashTemp.address);
                    while(1){}
                }
                count++;
            }
        }
        if(count == 1) continue;

        //check whether in OramTree
        //1. search the position map
        int leafIndex = position[targetIndex-1];
        for(int depthItr=1;depthItr<=GetDepth();depthItr++){
     
            struct Bucket *bucket = GetBucketOnPath(leafIndex,depthItr);
            
            for(int blockItr=0;blockItr<(BLOCKSINBUCKET-bucket->count);blockItr++){
                struct Block &block=bucket->blocks[blockItr];
                if(block.index==targetIndex){
                    size_t block_address = (size_t)bucket->nodeStartAddress + block.offset*SHADOWPAGESIZE;
                    count++;
                }
            }
        }

        if(count!=1){
            printf("can not find Index:%d on leaf:%d\n",targetIndex,leafIndex);
            while(1){}
        }
    }
    printf("%s,%d end\n",__func__,__LINE__);
    return 0;
}

size_t PathORAM::findABlock(size_t targetIndex,int currentCachePtr){
    size_t targetAddr=0;
    //check whether in cache
    for(int itr=0;itr<currentCachePtr;itr++){
        if(CacheIndex[itr]==targetIndex){
            targetAddr = CacheStart + itr*SHADOWPAGESIZE*CACHESPARENUM;
            return targetAddr;
        }
    }

    //check whether in stash
    for(int itr=0;itr<currentStashBoundry;itr++){
        struct StashMetadata &stashTemp=stash[itr];
        if(stashTemp.index==targetIndex){
            targetAddr= (size_t)stashTemp.address;
            return targetAddr;
        }
    }

    //check whether in OramTree
    //1. search the position map
    int leafIndex = position[targetIndex-1];
    for(int depthItr=1;depthItr<=GetDepth();depthItr++){
        struct Bucket *bucket = GetBucketOnPath(leafIndex,depthItr);
            
        for(int blockItr=0;blockItr<(BLOCKSINBUCKET-bucket->count);blockItr++){
            struct Block &block=bucket->blocks[blockItr];
            if(block.index==targetIndex){
                targetAddr = (size_t)bucket->nodeStartAddress + block.offset*SHADOWPAGESIZE;
                return targetAddr;
            }
        }
    }
    if(targetAddr==0){
        printf(" we find err: %lx\n",targetIndex);
    }
    return targetAddr; 
}

size_t PathORAM::getAPageMAC(size_t startAddress){
    size_t MAC=0;
    for(int i=0;i<SHADOWPAGESIZE;i+=8){
        size_t cur = *(size_t*)(startAddress+i);
        cur = (cur >> 32) + (cur & 0xffffffff);
        MAC+=cur;
    }
    return MAC;
}

size_t PathORAM::getARangeMAC(size_t startBlockAddr,size_t endBlockAddr,int currentCachePtr){
    // printf("startBlockAddr:%lx,endBlockAddr:%lx\n",startBlockAddr,endBlockAddr);
    
    int startOffet = startBlockAddr & ((1<<SHADOWPAGEWIDE)-1);
    int endBlockIndex = endBlockAddr >> SHADOWPAGEWIDE;
    int startBlockIndex = startBlockAddr >> SHADOWPAGEWIDE;
    int endOffet = endBlockAddr & ((1<<SHADOWPAGEWIDE)-1);
    size_t MAC = 0;
    size_t cur;
    int index=0;

    print_count++;
    if(print_count<=PRINTF_START_COUNT){
        return 0;
    }

    size_t targetBlockAddr = findABlock(startBlockIndex,currentCachePtr) + startOffet; //get start Address
    if(startBlockIndex==endBlockIndex){
        
        for(int offset=startOffet;offset<endOffet;offset+=8){
            cur = *(size_t *)targetBlockAddr;
            if(getAllValidPageMACTimes==PRINGMAC){
                printf("%d:addr:%lx:%lx\t",index,offset,cur);
                index++;
                if((index%5)==0)
                    printf("\n");
            }
            cur = (cur >> 32) + (cur & 0xffffffff);
            MAC+=cur;
            targetBlockAddr += 8;
            
        }
        
    }else{
        //handle the fisrt block
        for(int offset=startOffet;offset<SHADOWPAGESIZE;offset+=8){
            cur = *(size_t *)targetBlockAddr;
           if(getAllValidPageMACTimes==PRINGMAC){
                printf("%d:addr:%lx:%lx\t",index,offset,cur);
                index++;
                if((index%5)==0)
                    printf("\n");
            }
            cur = (cur >> 32) + (cur & 0xffffffff);
            MAC+=cur;
            targetBlockAddr += 8;
        }

        for(int indexItr=startBlockIndex+1;indexItr<endBlockIndex;indexItr++){
            targetBlockAddr = findABlock(indexItr,currentCachePtr);
            for(int offset=0;offset<SHADOWPAGESIZE;offset+=8){
                cur = *(size_t*)targetBlockAddr;
                if(getAllValidPageMACTimes==PRINGMAC){
                    printf("%d:addr:%lx:%lx\t",index,offset,cur);
                    index++;
                    if((index%5)==0)
                        printf("\n");
                }
                cur = (cur >> 32) + (cur & 0xffffffff);
                MAC+=cur;
                targetBlockAddr += 8;
            }
        }

        //the last block
        targetBlockAddr = findABlock(endBlockIndex,currentCachePtr);
        for(int offset=0;offset<endOffet;offset+=8){
            cur = *(size_t *)targetBlockAddr;
            if(getAllValidPageMACTimes==PRINGMAC){
                printf("%d:addr:%lx:%lx\t",index,offset,cur);
                index++;
                if((index%5)==0)
                    printf("\n");
            }
            cur = (cur >> 32) + (cur & 0xffffffff);
            MAC+=cur;
            targetBlockAddr += 8;
        }
    }

    if(getAllValidPageMACTimes==PRINGMAC){
        printf("\n");
    }
    printf("  getValid:%lx:                     MAC:%lx\n",getAllValidPageMACTimes,MAC);
    getAllValidPageMACTimes++;
    return MAC;
}

size_t PathORAM::getAllValidPageMAC(size_t cacheStartAddr,int *cacheIndexArray,int currentPtr,int *cacheSlotValidArray){
    size_t totalMACValue = 0;

    size_t singlePageAddr;
    size_t singlePageMAC;
    struct StashMetadata * stashMeta;

    size_t totalIndex = 0;
    //1. the pages in data cache.
    for(int itr=0;itr<currentPtr;itr++){
        if(itr<DATACACHE_MIN && !cacheSlotValidArray[itr])
            continue;
        singlePageAddr = cacheStartAddr + itr*SHADOWPAGESIZE*CACHESPARENUM;
        totalMACValue+=getAPageMAC(singlePageAddr);
        totalIndex += cacheIndexArray[itr];
    }
    //2. the pages in stash
    for(int itr=0;itr<currentStashBoundry;itr++){
        stashMeta  =  &stash[itr];
        if(stashMeta->index==0) continue;
        totalMACValue+=getAPageMAC((size_t)stashMeta->address);
        totalIndex += stashMeta->index;
    }

    // printf("getValid:total Index:%ld, MAC:%lx\n",getAllValidPageMACTimes,totalIndex,totalMACValue);
    return totalMACValue;
}