
# Also see "include/mbedtls/config.h"
CC = ../../build/Release/bin/clang 
AR = ../../build/Release/bin/llvm-ar
#LINKER = -Xlinker --supportBigObject

BASE_CFLAGS = -fno-asynchronous-unwind-tables\
			  -fno-jump-tables -fomit-frame-pointer\
			  -Wall -pedantic -Wno-unused-function -std=gnu11 -O3 -fno-unroll-loops -fno-inline

LIBSGXDIR = ../../../libsgx
CFLAGS = $(BASE_CFLAGS) -flto -fuse-ld=lld -I$(LIBSGXDIR)/include -I$(LIBSGXDIR)/musl-libc/include -I.\
		 -fno-stack-protector -fvisibility=hidden

LOCAL_CFLAGS = -Iinclude -I../ -D_FILE_OFFSET_BITS=64

OBJS_CRYPTO=	aes.o		aesni.o		arc4.o		\
		asn1parse.o	asn1write.o	base64.o	\
		bignum.o	blowfish.o	camellia.o	\
		ccm.o		cipher.o	cipher_wrap.o	\
		ctr_drbg.o	des.o		dhm.o		\
		ecdh.o		ecdsa.o		ecjpake.o	\
		ecp.o						\
		ecp_curves.o	entropy.o	entropy_poll.o	\
		error.o		gcm.o		havege.o	\
		hmac_drbg.o	md.o		md2.o		\
		md4.o		md5.o		md_wrap.o	\
		memory_buffer_alloc.o		oid.o		\
		padlock.o	pem.o		pk.o		\
		pk_wrap.o	pkcs12.o	pkcs5.o		\
		pkparse.o	pkwrite.o	platform.o	\
		ripemd160.o	rsa.o		sha1.o		\
		sha256.o	sha512.o	threading.o	\
		timing.o	version.o			\
		version_features.o		xtea.o

OBJS_X509=	certs.o		pkcs11.o	x509.o		\
		x509_create.o	x509_crl.o	x509_crt.o	\
		x509_csr.o	x509write_crt.o	x509write_csr.o

OBJS_TLS=	debug.o		ssl_cache.o	\
		ssl_ciphersuites.o		ssl_cli.o	\
		ssl_cookie.o	ssl_srv.o	ssl_ticket.o	\
		ssl_tls.o

.PHONY: all static clean

all: static

static: libmbedtls.a mbedtls #libmbedcrypto.a libmbedx509.a ssl_server.o

# tls
libmbedtls.a: $(OBJS_TLS) $(OBJS_X509) $(OBJS_CRYPTO) net.o
	echo "  AR    $@"
	$(AR) rs $@ $(OBJS_TLS) $(OBJS_TLS) $(OBJS_TLS) net.o
	echo "  RL    $@"
	$(AR) s $@

# x509
# libmbedx509.a: $(OBJS_X509)
# 	echo "  AR    $@"
# 	$(AR) -rc $@ $(OBJS_X509)
# 	echo "  RL    $@"
# 	$(AR) -s $@

# # crypto
# libmbedcrypto.a: $(OBJS_CRYPTO)
# 	echo "  AR    $@"
# 	$(AR) -rc $@ $(OBJS_CRYPTO)
# 	echo "  RL    $@"
# 	$(AR) -s $@

%.o: %.c
	$(CC) $(LOCAL_CFLAGS) $(CFLAGS) -c $<

mbedtls: $(OBJS_TLS) $(OBJS_X509) $(OBJS_CRYPTO) s_server.o net.o 
	$(CC) $(LOCAL_CFLAGS) $(CFLAGS) $(LINKER) -flto -fuse-ld=lld -Xlinker -image-base=0x400000 s_server.o net.o $(OBJS_TLS) $(OBJS_X509) $(OBJS_CRYPTO) -L../ -lFakeC -nostdlib -nostartfiles -o mbedtls 

clean:
	rm -f  libmbed* mbedtls
clean-all:
	rm -f *.o libmbed* mbedtls
