BASE_CFLAGS = -Wall -O2 -pedantic -Wno-unused-function -std=gnu11 
HOMEBUILD = ../build/Release/bin/

CC =  $(HOMEBUILD)/clang -fno-asynchronous-unwind-tables -fno-jump-tables -flto -fuse-ld=lld

# SGX LIB
LIBCDIR = musl-libc
SGX_CFLAGS = $(BASE_CFLAGS) -I$(LIBCDIR)/include \
             -fno-stack-protector -fvisibility=hidden  -fomit-frame-pointer 


LIBC = $(LIBCDIR)/lib/libc.a

STATIC_NOLIBC_FLAG = -nostdlib -nostartfiles

OCALL_OBJS_DIR = lib/
OCALL_LIB_MK = lib/ocall.mk

include $(OCALL_LIB_MK)

ASM_OBJS = lib/stack.o lib/start.o lib/rop_gadget.o \
		   lib/code_inject.o lib/ocall.o lib/rand_stub.o lib/mem.o #lib/syscall.o #lib/memcpy.o lib/syscall.o lib/memset.o \
		   #lib/strncmp.o\
	       #lib/memmove.o #lib/fabs.o 

#ASM_OBJS_PAN = lib/systemCallStub.o 
#ASM_OBJS_PAN = lib/systemCallStubRandom.o 
#ASM_OBJS_PAN = lib/systemCallStubrr.o 
ASM_OBJS_PAN = lib/systemCallStubmr.o 
# ASM_OBJS_PAN = lib/systemCallStub_supportBigObject.o 

ASM_S = lib/systemCallStub.s lib/systemCallStubRandom.s lib/systemCallStubrr.s lib/systemCallStubmr.s lib/systemCallStub_supportBigObject.S

LIBGCC = libgcc/ashldi3.o libgcc/ashrdi3.o libgcc/__divide_error.o 	\
		 libgcc/__divdi3.o libgcc/__divti3.o libgcc/__lshrdi3.o 	\
		 libgcc/multi3.o libgcc/__negti2.o libgcc/__udivdi3.o 		\
		 libgcc/__udivmoddi4.o libgcc/__udivmodti4.o 				\
		 libgcc/__umoddi3.o libgcc/__umodti3.o \
		 libgcc/__udivti3.o 

OBJS_CRYPTO=	mbedtls/aes.o		mbedtls/aesni.o		mbedtls/arc4.o		\
		mbedtls/asn1parse.o	mbedtls/asn1write.o	mbedtls/base64.o	\
		mbedtls/bignum.o	mbedtls/blowfish.o	mbedtls/camellia.o	\
		mbedtls/ccm.o		mbedtls/cipher.o	mbedtls/cipher_wrap.o	\
		mbedtls/ctr_drbg.o	mbedtls/des.o		mbedtls/dhm.o		\
		mbedtls/ecdh.o		mbedtls/ecdsa.o		mbedtls/ecjpake.o	\
		mbedtls/ecp.o						\
		mbedtls/ecp_curves.o	mbedtls/entropy.o	mbedtls/entropy_poll.o	\
		mbedtls/error.o		mbedtls/gcm.o		mbedtls/havege.o	\
		mbedtls/hmac_drbg.o	mbedtls/md.o		mbedtls/md2.o		\
		mbedtls/md4.o		mbedtls/md5.o		mbedtls/md_wrap.o	\
		mbedtls/memory_buffer_alloc.o		mbedtls/oid.o		\
		mbedtls/padlock.o	mbedtls/pem.o		mbedtls/pk.o		\
		mbedtls/pk_wrap.o	mbedtls/pkcs12.o	mbedtls/pkcs5.o		\
		mbedtls/pkparse.o	mbedtls/pkwrite.o	mbedtls/platform.o	\
		mbedtls/ripemd160.o	mbedtls/rsa.o		mbedtls/sha1.o		\
		mbedtls/sha256.o	mbedtls/sha512.o	mbedtls/threading.o	\
		mbedtls/timing.o	mbedtls/version.o			\
		mbedtls/version_features.o		mbedtls/xtea.o

OBJS_X509=	mbedtls/certs.o		mbedtls/pkcs11.o	mbedtls/x509.o		\
		mbedtls/x509_create.o	mbedtls/x509_crl.o	mbedtls/x509_crt.o	\
		mbedtls/x509_csr.o	mbedtls/x509write_crt.o	mbedtls/x509write_csr.o

OBJS_TLS=	mbedtls/debug.o		mbedtls/net.o		mbedtls/ssl_cache.o	\
		mbedtls/ssl_ciphersuites.o		mbedtls/ssl_cli.o	\
		mbedtls/ssl_cookie.o	mbedtls/ssl_srv.o	mbedtls/ssl_ticket.o	\
		mbedtls/ssl_tls.o

all: $(LIBC) libFakeC.a

$(LIBC):
	(cd musl-libc; ./configure)
	make -C musl-libc lib/libc.a


benchTest: ./benchmark/in_enclave_test.o
	$(CC) -flto -fuse-ld=lld -Xlinker -image-base=0x400000 -Xlinker --supportBigObject ./benchmark/in_enclave_test.o -L./ -lFakeC -nostdlib -nostartfiles -o benchTest

benchTest_nb: ./benchmark/bm_clock.o
	$(CC) -flto -fuse-ld=lld -Xlinker -image-base=0x400000 ./benchmark/bm_clock.o -L./ -lFakeC -nostdlib -nostartfiles -o benchTest


https: $(OBJS_TLS) $(OBJS_X509) $(OBJS_CRYPTO)
	$(CC) -flto -fuse-ld=lld -Xlinker -image-base=0x400000 mbedtls/s_server.o $(OBJS_TLS) $(OBJS_X509) $(OBJS_CRYPTO) -L. -lFakeC -nostdlib -nostartfiles -o https

program: objs/libc-aslr.a tools/linker $(OCALL_OBJS) $(ASM_OBJS)
	cp lib/*.o objs
	cp libgcc/*.o objs
	ls objs/*.o > list
	cat list | ./tools/linker program

libFakeC.a: objs/libc-aslr.a $(OCALL_OBJS) $(ASM_OBJS_PAN) $(LIBGCC) 
	cp $(ASM_OBJS_PAN) objs/
	cp libgcc/*.o objs/
	cp malloc.o objs/
	cp ./objs/libc.a libFakeC.a
	$(AR) rs libFakeC.a objs/*.o

lib/%.o: $(ASM_S) lib/%.cpp
	$(CC) -c -o $@ $<

libgcc/%.o: libgcc/%.c
	$(HOMEBUILD)clang -c $(SGX_CFLAGS) -o $@ $<

#$(HOMEBUILD)/clang -c $(SGX_CFLAGS) -o $@ $<

tools/linker: tools/linkage_editor.cpp
	$(CXX) -DDEBUG -g -o $@ $(LINKERFLAG) $^

objs/libc-aslr.a: $(LIBC)  malloc.o 
	cp $^ objs/

malloc.o: malloc/malloc.c malloc/dlmalloc.inc
	$(CC) -c $(SGX_CFLAGS) -o $@ $<

BENCHMARK=$(wildcard benchmark/*.c)
in_enclave_test.o: ./benchmark/in_enclave_test.c $(BENCHMARK) enclave.h
	$(CC) -c $(SGX_CFLAGS) -I. -o $@ $(LINKERFLAG) $<

bm_clock.o: ./benchmark/bm_clock.c $(BENCHMARK) enclave.h
	$(CC) -c $(SGX_CFLAGS) -I. -o $@ $(LINKERFLAG) $<

cleanBin:
	rm -f benchTest benchmark/*.o rm main

clean:
	rm -f *.o *.a objs/*.o objs/*.a list program https \
		tools/linker lib/*.o libgcc/*.o malloc/*.o benchmark/*.o benchTest

clean-all:
	rm -f *.o *.a objs/*.o libgcc/*.o objs/*.a list program https \
		tools/linker lib/*.o malloc/*.o
	$(MAKE) -C mbedtls clean
	$(MAKE) -C musl-libc clean
