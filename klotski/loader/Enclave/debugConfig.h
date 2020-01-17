//for debug

// whether we should trace the program's running
#define NO_DEBUG_FUNCTION_TRACE 1
#define DEBUG_FUNCTION_TRACE !(NO_DEBUG_FUNCTION_TRACE)

#define PRINT_EVEN_OBLIVIOUS_MODULE 0

#define PRINT_OUT_FUNCTION_TRACE 0                //Whether we should print out the Trace
#define FUNC_PRING_START_COUNT 0x223000                 //the number of function trace that we should ignore

                          
#define SCOUT_A_VIRUTAL_RANGE 0   //scout a [A:B] range's MAC
#define PRINTF_START_COUNT  0x4d00




// #define DEBUG_DATA_TRACE 1

//define djpeg
#define SCOUT_START_ADDR (heap_virtual_start[1] + 0x3c0+0x800*2)
#define SCOUT_END_ADDR (heap_virtual_start[1] + 0xf0da0+0x800*2)

// #define SCOUT_START_ADDR (heap_virtual_start[0] + 0x3c0 +0x800*2)
// #define SCOUT_END_ADDR (heap_virtual_start[0] + 0xf7da0 +0x800*2)
// #define SCOUT_START_ADDR 0x54b000
// #define SCOUT_END_ADDR 0x63a000

//define nbench
// #define SCOUT_START_ADDR (heap_virtual_start[1] + 0x3c0)
// #define SCOUT_END_ADDR (heap_virtual_start[1] + 0x228b0)

#define POINTER_HAS_TRANSLATED 1



// #define SCOUT_START_ADDR 0x4623c0
// #define SCOUT_END_ADDR 0x4848b0