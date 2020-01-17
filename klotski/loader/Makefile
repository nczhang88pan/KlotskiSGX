#
# Copyright (C) 2011-2016 Intel Corporation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#   * Neither the name of Intel Corporation nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#

### chose the target program
ifeq ($(TARGET),HTTPS)
	IN_ENCLAVE_PROGRAM=../program_for_lld/mbedtls/mbedtls
else ifeq ($(TARGET),TEST)
	#IN_ENCLAVE_PROGRAM=../program_for_lld/benchTest
	IN_ENCLAVE_PROGRAM=../program_for_lld/benchmark/benchTest
else ifeq ($(TARGET),CJPEG)
	IN_ENCLAVE_PROGRAM = ../libjpeg/testCase/cjpeg
else ifeq ($(TARGET),DJPEG)
	IN_ENCLAVE_PROGRAM = ../libjpeg/testCase/djpeg
else
	IN_ENCLAVE_PROGRAM=../nbench_Shiled/nbench_main
endif

### shall we enable the support of big object
ifeq ($(SBO),ON)
	DEF_SUPPORT_BIG_OBJECT = -DBIGOBJECTOSHUFFLE=1
else
	DEF_SUPPORT_BIG_OBJECT = -DBIGOBJECTOSHUFFLE=0
endif

### config the cache size
ifdef CACHENUM
	ORAM_CONIF += -DCACHENUM=$(CACHENUM)
else
	ORAM_CONIF += -DCACHENUM=2U
endif

### others

DEF_SYMBOL_SCRIPT =Enclave/define_symbols.lds

DEFINE_IN_ATTACK_H = -DRAND=0 -fomit-frame-pointer 
ifeq ($(RAND), OFF)
	DEFINE_IN_ATTACK_H = -DRAND=0
else
endif
ifeq ($(DEBUG), ON)
	DEFINE_IN_ATTACK_H += -DLD_DEBUG
endif
ifdef TECH
	DEFINE_IN_ATTACK_H += -DTECH=$(TECH)
endif
ifdef ATTACKER
	DEFINE_IN_ATTACK_H += -DATTACKER=$(ATTACKER)
endif

######## SGX SDK Settings ########

SGX_SDK ?= /opt/intel/sgxsdk/ 
SGX_MODE ?= HW
SGX_ARCH ?= x64
SGX_DEBUG ?= 1

SGX_SDK ?= ../sgxsdk/
SGX_MODE ?= SIM
SGX_ARCH ?= x64

ifeq ($(shell getconf LONG_BIT), 32)
	SGX_ARCH := x86
else ifeq ($(findstring -m32, $(CXXFLAGS)), -m32)
	SGX_ARCH := x86
endif

ifeq ($(SGX_ARCH), x86)
	SGX_COMMON_CFLAGS := -m32
	SGX_LIBRARY_PATH := $(SGX_SDK)/lib
	SGX_ENCLAVE_SIGNER := $(SGX_SDK)/bin/x86/sgx_sign
	SGX_EDGER8R := $(SGX_SDK)/bin/x86/sgx_edger8r
else
	SGX_COMMON_CFLAGS := -m64
	SGX_LIBRARY_PATH := $(SGX_SDK)/lib64
	SGX_ENCLAVE_SIGNER := $(SGX_SDK)/bin/x64/sgx_sign
	SGX_EDGER8R := $(SGX_SDK)/bin/x64/sgx_edger8r
endif

ifeq ($(SGX_DEBUG), 1)
ifeq ($(SGX_PRERELEASE), 1)
$(error Cannot set SGX_DEBUG and SGX_PRERELEASE at the same time!!)
endif
endif

ifeq ($(SGX_DEBUG), 1)
        SGX_COMMON_CFLAGS += -O2 -g
else
        SGX_COMMON_CFLAGS += -O2
endif

######## App Settings ########

ifneq ($(SGX_MODE), HW)
	Urts_Library_Name := sgx_urts_sim
else
	Urts_Library_Name := sgx_urts
endif

App_Cpp_Files := App/App.cpp
App_Include_Paths := -IInclude -I../program_for_lld/mbedtls/include -IApp -I$(SGX_SDK)/include

App_C_Flags := $(SGX_COMMON_CFLAGS) -Wno-attributes $(App_Include_Paths)

# Three configuration modes - Debug, prerelease, release
#   Debug - Macro DEBUG enabled.
#   Prerelease - Macro NDEBUG and EDEBUG enabled.
#   Release - Macro NDEBUG enabled.
ifeq ($(SGX_DEBUG), 1)
        App_C_Flags += -DDEBUG -UNDEBUG -UEDEBUG
else ifeq ($(SGX_PRERELEASE), 1)
        App_C_Flags += -DNDEBUG -DEDEBUG -UDEBUG
else
        App_C_Flags += -DNDEBUG -UEDEBUG -UDEBUG
endif

App_Cpp_Flags := $(App_C_Flags) -std=c++11
App_Link_Flags := $(SGX_COMMON_CFLAGS) -L$(SGX_LIBRARY_PATH) -l$(Urts_Library_Name) -lpthread 

ifneq ($(SGX_MODE), HW)
	App_Link_Flags += -lsgx_uae_service_sim
else
	App_Link_Flags += -lsgx_uae_service
endif

App_Cpp_Objects := $(App_Cpp_Files:.cpp=.o)

App_Name := app

######## Enclave Settings ########

ifneq ($(SGX_MODE), HW)
	Trts_Library_Name := sgx_trts_sim
	Service_Library_Name := sgx_tservice_sim
else
	Trts_Library_Name := sgx_trts
	Service_Library_Name := sgx_tservice
endif
Crypto_Library_Name := sgx_tcrypto

Enclave_Cpp_Files := Enclave/Enclave.cpp
Enclave_Include_Paths := -IInclude -IEnclave -I../program_for_lld/mbedtls/include -I$(SGX_SDK)/include -I$(SGX_SDK)/include/tlibc -I$(SGX_SDK)/include/stlport

Enclave_C_Flags := $(SGX_COMMON_CFLAGS) -mrtm -nostdinc -fvisibility=hidden -fpie -fstack-protector $(Enclave_Include_Paths)
Enclave_Cpp_Flags := $(Enclave_C_Flags) -std=c++03 -nostdinc++
Enclave_Link_Flags := $(SGX_COMMON_CFLAGS) -Wl,--no-undefined -nostdlib -nodefaultlibs -nostartfiles -L$(SGX_LIBRARY_PATH) \
	-Wl,--whole-archive -l$(Trts_Library_Name) -Wl,--no-whole-archive \
	-Wl,--start-group -lsgx_tstdc -lsgx_tstdcxx -l$(Crypto_Library_Name) -l$(Service_Library_Name) -Wl,--end-group \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic  \
	-Wl,--defsym,__ImageBase=0 \
	-Wl,--version-script=Enclave/Enclave.lds

Enclave_Cpp_Objects := $(Enclave_Cpp_Files:.cpp=.o)

NoSGX := nosgx
Enclave_Name := enclave.so
Signed_Enclave_Name := enclave.signed.so
Enclave_Config_File := Enclave/Enclave.config.xml

ifeq ($(SGX_MODE), HW)
ifneq ($(SGX_DEBUG), 1)
ifneq ($(SGX_PRERELEASE), 1)
Build_Mode = HW_RELEASE
endif
endif
endif


.PHONY: all run

ifeq ($(Build_Mode), HW_RELEASE)
all: $(App_Name) $(Enclave_Name)
	@echo "The project has been built in release hardware mode."
	@echo "Please sign the $(Enclave_Name) first with your signing key before you run the $(App_Name) to launch and access the enclave."
	@echo "To sign the enclave use the command:"
	@echo "   $(SGX_ENCLAVE_SIGNER) sign -key <your key> -enclave $(Enclave_Name) -out <$(Signed_Enclave_Name)> -config $(Enclave_Config_File)"
	@echo "You can also sign the enclave using an external signing tool. See User's Guide for more details."
	@echo "To build the project in simulation mode set SGX_MODE=SIM. To build the project in prerelease mode set SGX_PRERELEASE=1 and SGX_MODE=HW."
else
all: $(App_Name) $(Signed_Enclave_Name)
endif

run: all
ifneq ($(Build_Mode), HW_RELEASE)
	@$(CURDIR)/$(App_Name)
	@echo "RUN  =>  $(App_Name) [$(SGX_MODE)|$(SGX_ARCH), OK]"
endif

######## App Objects ########
MBEDTLS_UNTRUSTED_OBJ_FILES := App/mbedtls_sgx_u_net.c
MBEDTLS_UNTRUSTED_OBJECTS := $(MBEDTLS_UNTRUSTED_OBJ_FILES:.c=.u.o)

App/Enclave_u.c: $(SGX_EDGER8R) Enclave/Enclave.edl
	@cd App && $(SGX_EDGER8R) --untrusted ../Enclave/Enclave.edl --search-path ../Enclave --search-path $(SGX_SDK)/include
	@echo "GEN  =>  $@"

App/Enclave_u.o: App/enclave.c App/Enclave_u.c	
	@$(CC) $(App_C_Flags) -c $< -o $@
	@echo "CC   <=  $<"

App/attack.o: App/attack.s
	@$(CC) $(App_C_Flags) -c $< -o $@
	@echo "CC   <=  $<"

App/measurement.o: App/measurement.c
	@$(CC) $(App_C_Flags) -c $< -o $@
	@echo "CC   <=  $<"

App/App.o: App/App.cpp App/ocall.cpp
	@$(CXX) $(App_Cpp_Flags) $(DEFINE_IN_ATTACK_H) -c $< -o $@
	@echo "CXX  <=  $<"

App/%.u.o: $(MBEDTLS_UNTRUSTED_OBJ_FILES)
	@$(CC) $(App_C_Flags) -I../program_for_lld/mbedtls/include -c -o $@ $<
	@echo "CC <= $<"

$(App_Name): App/Enclave_u.o App/attack.o App/App.o App/measurement.o $(MBEDTLS_UNTRUSTED_OBJECTS)
	@$(CXX) $^ -o $@ $(App_Link_Flags)
	@echo "LINK =>  $@"


######## Enclave Objects ########
Enclave/Enclave_t.c: $(SGX_EDGER8R) Enclave/Enclave.edl
	@cd Enclave && $(SGX_EDGER8R) --trusted ../Enclave/Enclave.edl --search-path ../Enclave --search-path $(SGX_SDK)/include
	@echo "GEN  =>  $@"

Enclave/ocall_type.h: gen_def.c
	@$(CC) $< -o gen_def
	@./gen_def > Enclave/ocall_type.h

Enclave/Enclave_t.o: Enclave/enclave.c Enclave/Enclave_t.c Enclave/ocall_type.h
	@$(CC) $(Enclave_C_Flags) -c $< -o $@
	@echo "CC   <=  $<"

Enclave/measure/Omeasure.o: Enclave/measure/Omeasure.cpp
	$(CXX)  $(Enclave_Cpp_Flags) -O3 $(DEFINE_IN_ATTACK_H) -c $< -o $@
	@echo "CXX  <=  $<"

Enclave/ORAM/PathOram.o: Enclave/ORAM/PathOram.cpp
	$(CXX)  $(Enclave_Cpp_Flags) $(ORAM_CONIF) -O3  $(DEFINE_IN_ATTACK_H) -c $< -o $@
	@echo "CXX  <=  $<"

Enclave/%.o: Enclave/%.cpp $(IN_ENCLAVE_PROGRAM)
	$(CXX) $(Enclave_Cpp_Flags) $(DEFINE_IN_ATTACK_H) $(ORAM_CONIF) $(DEF_SUPPORT_BIG_OBJECT)  -c $< -o $@
	@objcopy --add-section .sgx.bin=$(IN_ENCLAVE_PROGRAM) --set-section-flags .sgx.bin=alloc,data,code $@
	@fallocate -l 32M blob
	@fallocate -l 24M pathOram
	@fallocate -l 15M pathOramData
	@fallocate -l 15M pathOramBigData
	@objcopy --add-section .sgx.code=blob --set-section-flags .sgx.code=alloc,data,code $@
	@objcopy --add-section .sgx.pathOram=pathOram --set-section-flags .sgx.pathOram=alloc,data,code $@
	@objcopy --add-section .sgx.pathOramData=pathOramData --set-section-flags .sgx.pathOramData=alloc,data $@
	@objcopy --add-section .sgx.pathOramBigData=pathOramBigData --set-section-flags .sgx.pathOramBigData=alloc,data $@
	@echo "CXX  <=  $<"

$(Enclave_Name): Enclave/Enclave_t.o Enclave/ORAM/PathOram.o Enclave/measure/Omeasure.o $(Enclave_Cpp_Objects)
	@$(CXX) $^ -o $@ $(Enclave_Link_Flags) $(DEF_SYMBOL_SCRIPT)
	@echo "LINK =>  $@"

nosgx.o: nosgx.cpp
	@$(CXX) $(DEFINE_IN_ATTACK_H) -g -c $^ -o $@
	@objcopy --add-section .sgx.bin=$(IN_ENCLAVE_PROGRAM) --set-section-flags .sgx.bin=alloc,data $@
	@fallocate -l 2M blob
	@objcopy --add-section .sgx.code=blob --set-section-flags .sgx.code=alloc,data,code $@
	@echo "CXX =>  $@"

$(NoSGX): nosgx.o
	@mkdir -p tmp/
	@$(CXX) $^ -o $@ $(DEF_SYMBOL_SCRIPT)
	@echo "LINK program =>  $@"

$(Signed_Enclave_Name): $(Enclave_Name)
	@$(SGX_ENCLAVE_SIGNER) sign -key Enclave/Enclave_private.pem -enclave $(Enclave_Name) -out $@ -config $(Enclave_Config_File)
	@echo "SIGN =>  $@"

.PHONY: clean

clean:
	@rm -f $(App_Name) $(Enclave_Name) $(Signed_Enclave_Name) $(App_Cpp_Objects) App/Enclave_u.* $(Enclave_Cpp_Objects) Enclave/Enclave_t.* \
		blob pathOram nosgx.o nosgx App/attack.o gen_def Enclave/ocall_type.h libmbedtls.a ../program_for_lld/mbedtls/*.o Enclave/ORAM/PathOram.o Enclave/measure/Omeasure.o pathOramData pathOramBigData
