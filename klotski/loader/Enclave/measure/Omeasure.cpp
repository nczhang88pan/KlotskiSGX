#include "./OMeasure.h"
#include "../Enclave.h"

//numberetEventNumr of call
size_t callMissingEventNum;
//number of ret
size_t retMissingEventNum;
//number of fallthrough
size_t fallthroughMissingEventNum;
//number of data dereference
size_t dataDereferenceMissingEventNum;

size_t cacheFlushNum;

void OMeasureInit(){
#if Do_Event_Measure
    callEventNum=0;
    retEventNum=0;
    dataDereferenceEventNum=0;
    fallthrough=0;
    callMissingEventNum=0;
    retMissingEventNum=0;
    fallthroughMissingEventNum=0;
    dataDereferenceMissingEventNum=0;
    cacheFlushNum=0;

    // printf("CALL Event: %ld\n",callEventNum);
    // printf("CALL Missing Event: %ld\n",callMissingEventNum);

    // printf("RET Event: %ld\n",retEventNum);
    // printf("RET Missing Event: %ld\n",retMissingEventNum);

    // printf("fallthrough Event: %ld\n",fallthrough);
    // printf("fallthrough Missing Event: %ld\n",fallthroughMissingEventNum);

    // printf("data Event: %ld\n",dataDereferenceEventNum);
    // printf("data Missing Event: %ld\n",dataDereferenceMissingEventNum);

    // printf("cacheFlushNum Event: %ld\n",cacheFlushNum);
#endif
}

void coutResults(double iter){
    static int times = 0;
    static double iters=0.0;
    static size_t codeCount=0;
    static size_t dataCount=0;
#if Do_Event_Measure
    // printf("CALL Event: %ld\n",callEventNum);
    // printf("CALL Missing Event: %ld\n",callMissingEventNum);

    // printf("RET Event: %ld\n",retEventNum);
    // printf("RET Missing Event: %ld\n",retMissingEventNum);

    // printf("fallthrough Event: %ld\n",fallthrough);
    // printf("fallthrough Missing Event: %ld\n",fallthroughMissingEventNum);

    // printf("data Event: %ld\n",dataDereferenceEventNum);
    // printf("data Missing Event: %ld\n",dataDereferenceMissingEventNum);

    // printf("cacheFlushNum Event: %ld\n",cacheFlushNum);
    size_t totalResult = callEventNum + retEventNum + fallthrough;
    size_t MissingResult = callMissingEventNum + retMissingEventNum + fallthroughMissingEventNum;
    codeCount += totalResult;
    dataCount += dataDereferenceEventNum;
    // printf("EC missint rate:%.13f\n",(double)retMissingResult/(double)totalResult);
    // printf("EC missing Event:%ld\n",retMissingResult);
    // printf("EC event:%ld\n",totalResult);
    // printf("dataDereferenceEventNum:%ld\n",dataDereferenceEventNum);
    // printf("totalControlflowResult:%ld\n",totalResult);
    // printf("totalDereference:%ld\n",dataDereferenceEventNum+totalResult);
    // printf("EC iteration:%.13f\n",iter);
    // printf("iter:\t%.13f\n",iter);
    times++;
    // if(times==5){

        // printf("\tper iteration data Dereference:\t%.13f\n",(double)(dataDereferenceEventNum)/iter);

        // printf("data Missing Event: %ld\n",dataDereferenceMissingEventNum);
        // printf("\tdata Event: %ld\n",dataDereferenceEventNum);
        // printf("\tper iteration data Dereference:%.13f\n",(double)(dataCount)/iters);
        

        // printf("code Missing Event: %ld\n",MissingResult);
        // printf("\tcode Event: %ld\n",totalResult);
        // printf("\tper iteration code Dereference:\t%.13f\n",(double)(codeCount)/iter);
    #if isCountStastic
        printf("\tper iteration data Dereference:%.13f\n",(double)(dataCount)/iter);
        printf("\tper iteration code Dereference:\t%.13f\n",(double)(codeCount)/iter);

    #else
        printf("Data hit rate:%.13f\n",1.0 - (double)dataDereferenceMissingEventNum/dataDereferenceEventNum);
        printf("code hit rate:%.13f\n",1.0 - (double)MissingResult/totalResult);
    #endif
        
        times = 0;
        dataCount=0;
        codeCount=0;
    // }

    // callEventNum=0;
    // retEventNum=0;
    // dataDereferenceEventNum=0;
    // fallthrough=0;
    // callMissingEventNum=0;
    // retMissingEventNum=0;
    // fallthroughMissingEventNum=0;
    // dataDereferenceMissingEventNum=0;
    // cacheFlushNum=0;
    
#endif
}