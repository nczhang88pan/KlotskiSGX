add_llvm_library(LLVMInstrumentation
  AddressSanitizer.cpp
  BoundsChecking.cpp
  DataFlowSanitizer.cpp
  GCOVProfiling.cpp
  MemorySanitizer.cpp
  IndirectCallPromotion.cpp
  Instrumentation.cpp
  InstrProfiling.cpp
  PGOInstrumentation.cpp
  SanitizerCoverage.cpp
  ThreadSanitizer.cpp
  EfficiencySanitizer.cpp
  EliminateConstantInAFunctionBody.cpp
  Klotski/Annotation.cpp
  Klotski/Allocation.cpp
  Klotski/CallGraph.cpp
#  Klotski/STaint.cpp
  Klotski/unSafeObject.cpp
  Klotski/DataAnalysis.cpp
  Klotski/DeIRInstructionInsert.cpp
  EliminateRedundantDeIR.cpp
  ADDITIONAL_HEADER_DIRS
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/Transforms

  DEPENDS
  intrinsics_gen
  )
