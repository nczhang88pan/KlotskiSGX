# Klotski document
## compile klotski in a docker
### 1.setup the docker
1. Build the docker image: 
	`sudo docker build --network=host -t klotski .`
2. Search the created image: 
	`sudo docker image ls ` and copy that IMAGE ID
3. start the docker image:
	`sudo docker run --rm -it  -v ${KLOTSKIDIR}:/home/alax/Klotski --net=host klotski`
    
    `#sudo docker run --privileged --cap-add=ALL -it -v /dev:/dev -v /lib/modules:/lib/modules  -v ${KLOTSKIDIR}:/home/alax/Klotski -v ${KLOTSKIDIR}/sgxsdk:/home/alax/SGX/sgxsdk --net=host klotskipan`

### 2.compile the code in the docker
#### 2.1 compile the sgx sdk and psw
1. `cd /home/alax/Klotski/linux-sgx && make`
2. `./download_prebuilt.sh`
3. `make sdk_install_pkg` 
4. `make psw_install_pkg` 

#### 2.2 compile LLVM
##### 1.1 generate LLVM configuration files
```
cd ${KLOTSKIDIR}
mkdir ${KLOTSKIDIR}/build/Release 
cd ${KLOTSKIDIR}/build/Release	

cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=host -DLLVM_TARGET_ARCH=host -DLLVM_ENABLE_ASSERTIONS=On -DLLVM_ENABLE_PROJECTS="lld;clang" -DLLVM_EXTERNAL_LLD_SOURCE_DIR="../../llvmProgram/lld" -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="../../llvmProgram/clang" -G "CodeBlocks - Unix Makefiles" ../../llvmProgram/llvm
```
##### 1.2 generate clang && lld && llvm-ar
clang:
`cmake --build . --target clang -- -j 8`
lld:
`cmake --build . --target lld -- -j 8`
llvm-ar
`cmake --build . --target llvm-ar -- -j 8`

## run program outsite of the docker
### 3. compile the target protected program
the target programs are generated outside of the docker, because the psw service can not work well in the docker.
Thus in this step, we are operating in **{KlotskiDir}**
#### 3.1 install the intel SGX driver && SDK && PSW
```
#install driver
make && sudo insmod isgx.ko

#install SDK && PSW
cd ${KLOTSKIDIR}/linux-sgx/linux/installer/bin/
./sgx_linux_x64_sdk_${version}.bin     #chose {no} and install the SDK to {KlotskiDir}/sgxsdk
source ${KLOTSKIDIR}/sgxsdk/environment #recommend to add it to the .bashrc file
./sgx_linux_x64_pwd_${version}.bin

```
#### 4. the modified files in llvm
##### 4.1 IR layer
llvmProgram/llvm/lib/Transforms/Instrumentation/
1. DeIRInstructionInsert.cpp       ##insert dereference code for data
2. DataAnalysis.cpp/.h   	          ##pre-dataAnalysis
3. EliminateRedundantDeIR.cpp 
4. unSafeObject.cpp/.h      ##support big data object (larger thatn a block)

##### 4.2 backend
llvmProgram/llvm/lib/Target/X86/
1. X86MCInstLower.cpp (insert dereference code for code)
2. MCAssembler.cpp/.h (generate the binary code, split the code and data into blocks. Functions are comment with PZ in MCAssembler.h)
3. MCFragment.cpp/.h data structure for split code and data. (FT_MBBegin/FT_Constant/FT_MBEnd)

#### import Oblivious execution configuration
1.  **${KLOTSKIDIR}/loader/Enclave/ORAM/ORAM.hpp**
	- \#define  CACHENUM  2               //shadow page number for code
	- \#define  DATACACHE_MIN  2U  //shadow page number for data
2. **${KLOTSKIDIR}/loader/Enclave/loader.h**
	- \#define  OBLIVIOUSSHUFFLE  1  //code oblivious enable
	- \#define  DATAOBLIVIOUSSHUFFLE  1  //data(small) oblivious enable
	- \#define  BIGOBJECTOSHUFFLE  0  //data(big) oblivious enable
	- \#define  PAGE_SWAP_AT_OCALL  0  //swap the pages existed in cache back to the ORAM tree at each Ocall


