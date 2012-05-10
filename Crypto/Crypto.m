//
//  Crypto.m
//  IMosh
//
//  Created by Kerry on 4/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "Base64.h"
#include "Byteorder.h"
#import "Crypto.h"

#include "cpp.h"
#include <sys/resource.h>

const char rdev[] = "/dev/urandom";

long int myatoi(const char* str) {
	char* end;
	errno = 0;
	long int ret = strtol(str, &end, 10);
	
	if ((errno != 0) || (end != str + strlen(str))) {
		@throw [[[CryptoNSCryptoException alloc]
				initWithText:@"Bad integer."] autorelease];
	}
	return ret;
}
// -----------------------------------------------------------------------------
@implementation CryptoNSCryptoException

// getters and setters
@synthesize text;
@synthesize fatal;

- (id)initWithTextAndFatal:(NSString*)sText :(BOOL)sFatal {
	if (self = [super init]) {
		[self setText:(NSString*)sText];
		[self setFatal:(BOOL)sFatal];
	}
	return self;
}

- (id)initWithText:(NSString*)sText {
	return [self initWithTextAndFatal:sText :FALSE];
}

@end
// -----------------------------------------------------------------------------
@implementation CryptoNSAlignedBuffer

// getters and setters
@synthesize mLen;
@synthesize mAllocated;
@synthesize mData;

- (id)initWithLenAndData:(size_t)len :(char*)data {
	if (self = [super init]) {
		[self setMLen:len];
		[self setMAllocated:NULL];
		[self setMData:NULL];
		
#if defined(HAVE_POSIX_MEMALIGN)
		if ((0 != posix_memalign(&mAllocated, 16, len)) || (mAllocated == NULL)) {
			badAlloc();
		}
		mData = (char*)(mAllocated);
		
#else
		mAllocated = malloc(15 + len);
		if (mAllocated == NULL) {
			badAlloc();
		}
		
		uintptr_t iptr = (uintptr_t)(mAllocated);
		if (iptr & 0xF) {
			iptr += 16 - (iptr & 0xF);
		}
		NSAssert(!(iptr & 0xF), @"Bad iptr");
		NSAssert(iptr >= (uintptr_t)(mAllocated), @"Bad iptr lower bound");
		NSAssert(iptr <= (15 + (uintptr_t)(mAllocated)), @"Bad iptr upper bound");
		
		mData = (char*)(iptr);
#endif
		if (data) {
			memcpy(mData, data, len);
		}
	}
	return self;
}

- (id)initWithLen:(size_t)len {
	return [self initWithLenAndData:len :NULL];
}

/*
Not implemented
- (id)initWithAlignedBuffer:(CryptoNSAlignedBuffer*)alignedBuffer {
}
*/

/*
 Not implemented
- (id)assignment:(CryptoNSAlignedBuffer*)alignedBuffer {
}
*/

- (void)dealloc {
	free(mAllocated);
	[super dealloc];
}

- (char*)data {
	return mData;
}

- (size_t)len {
	return mLen;
}

@end
// -----------------------------------------------------------------------------
@implementation CryptoNSBase64Key

- (id)initWithPrintableKey:(NSString*)printableKey {
	self = [super init];
	if (!self) {
		return self;
	}
	
	if ([printableKey length] != 22) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Key must be 22 letters long."] autorelease];
	}
	
	NSString* base64 = [printableKey stringByAppendingString:@"=="];
	
	size_t len = 16;
	if (!base64_decode([base64 UTF8String], 24, (char*)(&key[0]), &len)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Key must be well-formed base64."] autorelease];
	}
	
	if (len != 16) {
		@throw [[[CryptoNSCryptoException alloc]
				initWithText:@"Key must represent 16 octets."] autorelease];
	}
	
	if (printableKey != [self printableKey]) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Base64 key was not encoded 128-bit key."] autorelease];
	}
	return self;
}

// TODO: make only one allocator
- (id)initWithRandomKey {
	self = [super init];
	if (!self) {
		return self;
	}
	
	FILE* devrandom = fopen(rdev, "r");
	if (devrandom == NULL) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:[NSString stringWithFormat:@"%@: %@",
							 [NSString stringWithCString:rdev],
							 strerror(errno)]] autorelease];
	}
	
	if (1 != fread(key, 16, 1, devrandom)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:[NSString stringWithFormat:@"Could not read from %@",
							 [NSString stringWithCString:rdev]]] autorelease];
	}
	
	if (0 != fclose(devrandom)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:[NSString stringWithFormat:@"%@: %@",
							   [NSString stringWithCString:rdev],
							   strerror(errno)]] autorelease];
	}
	return self;
}

- (NSString*)printableKey {
	char base64[25];
	
	base64_encode((char*)(key), 16, base64, 25);
	
	if ((base64[24] != 0) || (base64[23] != '=') || (base64[22] != '=')) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Unexpected output from base64_encode."] autorelease];
	}
	
	base64[22] = 0;
	return [NSString stringWithCString:base64];
}

- (unsigned char*)data {
	return key;
}

@end
// -----------------------------------------------------------------------------
@implementation CryptoNSNonce

- (id)initWithVal:(uint64_t)val {
	if (self = [super init]) {
		uint64_t valNet = htobe64(val);
	
		memset(bytes, 0, 4);
		memcpy(bytes + 4, &valNet, 8);
	}
	return self;
}

// TODO: make only one allocator
- (id)initWithBytesAndLen:(char*)sBytes :(size_t)len {
	if (self = [super init]) {
		if (len != 8) {
			@throw [[[CryptoNSCryptoException alloc]
					 initWithText:@"Nonce representation must be 8 octets long."] autorelease];
		}
		
		memset(bytes, 0, 4);
		memcpy(bytes + 4, sBytes, 8);
	}
	return self;
}

- (NSString*)ccStr {
	return stringFromCharPtrAndLength(bytes + 4, 8);
}

- (char*)data {
	return bytes;
}

- (uint64_t)val {
	uint64_t ret;
	memcpy(&ret, bytes + 4, 8);
	return be64toh(ret);
}

@end
// -----------------------------------------------------------------------------
@implementation CryptoNSMessage

// getters and setters
@synthesize nonce;
@synthesize text;

- (id)initWithNonceBytesAndTextBytes:(char*)nonceBytes :(size_t)nonceLen :(char*)textBytes :(size_t)textLen {
	if (self = [super init]) {
		nonce = [[CryptoNSNonce alloc] initWithBytesAndLen:nonceBytes :nonceLen];
		// modification to make it 
		text = stringFromCharPtrAndLength(textBytes, textLen);
	}
	return self;
}

// TODO: make only one allocator, and check that copying sNonce is okay
- (id)initWithNonceAndText:(CryptoNSNonce*)sNonce :(NSString*)sText {
	if (self = [super init]) {
		nonce = [sNonce copy];
		text = sText;
	}
	return self;
}

- (void)dealloc {
	[nonce release];
	[super dealloc];
}

@end
// -----------------------------------------------------------------------------
@implementation CryptoNSSession

- (id)initWithBase64Key:(CryptoNSBase64Key*)sKey {
	if (self = [super init]) {
		key = sKey;
		ctxBuf = [[CryptoNSAlignedBuffer alloc] initWithLen:ae_ctx_sizeof()];
		ctx = (ae_ctx*)([ctxBuf data]);
		blocksEncrypted = 0;
		plaintextBuffer = [[CryptoNSAlignedBuffer alloc] initWithLen:CryptoNSSessionReceiveMTU];
		ciphertextBuffer = [[CryptoNSAlignedBuffer alloc] initWithLen:CryptoNSSessionReceiveMTU];
		nonceBuffer = [[CryptoNSAlignedBuffer alloc] initWithLen:CryptoNSNonceNonceLen];
		
		if (AE_SUCCESS != ae_init(ctx, [key data], 16, 12, 16)) {
			@throw [[[CryptoNSCryptoException alloc]
					 initWithText:@"Could not initialize AES-OCB context."] autorelease];
		}
	}
	return self;
}
- (void)dealloc {
	if (ae_clear(ctx) != AE_SUCCESS) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Could not clear AES-OCB context."] autorelease];
	}
	[ctxBuf release];
	[plaintextBuffer release];
	[ciphertextBuffer release];
	[nonceBuffer release];
	[super dealloc];
}

- (NSString*)encrypt:(CryptoNSMessage*)plaintext {
	const size_t ptLen = [[plaintext text] length];
	const int ciphertextLen = ptLen + 16;
	
	NSAssert((size_t)(ciphertextLen) <= [ciphertextBuffer len], @"Ciphertext buffer too small");
	NSAssert(ptLen <= [plaintextBuffer len], @"Plaintext buffer too small");
	
	memcpy([plaintextBuffer data], [[plaintext text] UTF8String], ptLen);
	memcpy([nonceBuffer data], [[plaintext nonce] data], CryptoNSNonceNonceLen);
	
	if (ciphertextLen != ae_encrypt(ctx,
									[nonceBuffer data],
									[plaintextBuffer data], 
									ptLen,
									NULL,
									0,
									[ciphertextBuffer data], 
									NULL,
									AE_FINALIZE)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"ae_encrypt() returned error."] autorelease];
	}
	
	blocksEncrypted += ptLen >> 4;
	if (ptLen & 0xF) {
		blocksEncrypted++;
	}
	
	if (blocksEncrypted >> 47) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithTextAndFatal:@"Encrypted 2^47 blocks." :TRUE] autorelease];
	}
	
	NSString* text = stringFromCharPtrAndLength([ciphertextBuffer data], ciphertextLen);
	return [[[plaintext nonce] ccStr] stringByAppendingString:text];
}
- (CryptoNSMessage*)decrypt:(NSString*)ciphertext {
	if ([ciphertext length] < 24) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Ciphertext must contain nonce and tag."] autorelease]; 
	}
	
	char* str = (char*)([ciphertext UTF8String]);
	
	int bodyLen = [ciphertext length] - 8;
	int ptLen = bodyLen - 16;
	
	if (ptLen < 0) {
		fprintf(stderr, "BUG.\n");
		exit(1);
	}
	
	NSAssert((size_t)(bodyLen) <= [ciphertextBuffer len], @"Body too long");
	NSAssert((size_t)(ptLen) <= [plaintextBuffer len], @"Plaintext too long");
	
	CryptoNSNonce* nonce = [[CryptoNSNonce alloc] initWithBytesAndLen:str :8];
	memcpy([ciphertextBuffer data], str + 8, bodyLen);
	memcpy([nonceBuffer data], [nonce data], CryptoNSNonceNonceLen);
	
	if (ptLen != ae_decrypt(ctx,
							[nonceBuffer data],
							[ciphertextBuffer data],
							bodyLen,
							NULL,
							0,
							[plaintextBuffer data],
							NULL,
							AE_FINALIZE)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:@"Packet failed integrity check."] autorelease];
	}
	
	CryptoNSMessage* ret = [[CryptoNSMessage alloc]
							initWithNonceAndText
							:nonce
							:stringFromCharPtrAndLength([plaintextBuffer data], ptLen)];
	
	[nonce release];
	return [ret autorelease];
}

static rlim_t savedCoreRlimit;

// copy constructor
//- (id)initWithSession:(CryptoNSSession*)session {
//}

// assignment operator
//- (id)assignment:(CryptoNSSession*)session {
//}

@end
// -----------------------------------------------------------------------------
void cryptoNSDisableDumpingCore() {
	struct rlimit limit;
	
	if (0 != getrlimit(RLIMIT_CORE, &limit)) {
		perror("getrlimit(RLIMIT_CORE)");
		exit(1);
	}
	
	savedCoreRlimit = limit.rlim_cur;
	limit.rlim_cur = 0;
	if (0 != setrlimit(RLIMIT_CORE, &limit)) {
		perror("setrlimit(RLIMIT_CORE)");
		exit(1);
	}
}

void cryptoNSReenableDumpingCore() {
	struct rlimit limit;
	if (0 == getrlimit(RLIMIT_CORE, &limit)) {
		limit.rlim_cur = savedCoreRlimit;
		setrlimit(RLIMIT_CORE, &limit);
	}
}

