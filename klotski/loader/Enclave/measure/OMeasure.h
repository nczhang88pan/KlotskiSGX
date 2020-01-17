#ifndef _OMEASURE_H_
#define	_OMEASURE_H_ 1
#include "../Enclave.h"

#define Do_Event_Measure 0
#define isCountStastic 0


//numberetEventNumr of call
extern size_t callEventNum;
//number of ret
extern size_t retEventNum;
//number of fallthrough
extern size_t fallthrough;
//number of data dereference
extern size_t dataDereferenceEventNum;

//numberetEventNumr of call
extern size_t callMissingEventNum;
//number of ret
extern size_t retMissingEventNum;
//number of fallthrough
extern size_t fallthroughMissingEventNum;
//number of data dereference
extern size_t dataDereferenceMissingEventNum;

extern size_t cacheFlushNum;

#if Do_Event_Measure
#define CALLE_MISSING_EVENT_INC() callMissingEventNum+=1;
#define RET_MISSING_EVENT_INC() retMissingEventNum+=1;
#define FALLTHROUGH_MISSING_EVENT_INC() fallthroughMissingEventNum+=1;
#define DATE_MISSING_EVENT_INC() dataDereferenceMissingEventNum+=1;
#define CACHE_FLUSH_EVENT_INC() cacheFlushNum+=1;

#define DATE_EVENT_INC()\
"incq %1\n"

#define RET_EVENT_INC()\
"incq %4\n"

#define FALLTHROUGH_EVENT_INC()\
"incq %1\n"

#define CALL_EVENT_INC()\
"incq %1\n"

#else
#define CALLE_MISSING_EVENT_INC() 
#define RET_MISSING_EVENT_INC() 
#define FALLTHROUGH_MISSING_EVENT_INC() 
#define DATE_MISSING_EVENT_INC() 

#define DATE_EVENT_INC() 
#define RET_EVENT_INC() 
#define FALLTHROUGH_EVENT_INC()
#define CALL_EVENT_INC()
#define CACHE_FLUSH_EVENT_INC()
#endif //Do_Event_Measure


void OMeasureInit();
void coutResults(double iter);


#endif