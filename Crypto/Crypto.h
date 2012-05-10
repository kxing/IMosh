//
//  Crypto.h
//  IMosh
//
//  Created by Kerry on 4/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AE.h"
// -----------------------------------------------------------------------------
@interface CryptoNSCryptoException : NSException {
	@private
	NSString* text;
	BOOL fatal;
}
@property (copy) NSString* text;
@property (assign) BOOL fatal;

- (id)initWithTextAndFatal:(NSString*)sText :(BOOL)sFatal;
- (id)initWithText:(NSString*)sText;

@end
// -----------------------------------------------------------------------------
@interface CryptoNSAlignedBuffer : NSObject {
	@private
	size_t mLen;
	void* mAllocated;
	char* mData;
}
@property (assign) size_t mLen;
@property (assign) void* mAllocated;
@property (assign) char* mData;

- (id)initWithLenAndData:(size_t)len :(char*)data;
- (id)initWithLen:(size_t)len;
// copy constructor
//- (id)initWithAlignedBuffer:(CryptoNSAlignedBuffer*)alignedBuffer;
// assignment operator
//- (id)assignment:(CryptoNSAlignedBuffer*)alignedBuffer;
- (void)dealloc;

- (char*)data;
- (size_t)len;

@end
// -----------------------------------------------------------------------------
@interface CryptoNSBase64Key : NSObject {
	@private
	unsigned char key[16];
}

- (id)initWithPrintableKey:(NSString*)printableKey;
- (id)initWithRandomKey;

- (NSString*)printableKey;
- (unsigned char*)data;

@end
// -----------------------------------------------------------------------------
#define CryptoNSNonceNonceLen 12
@interface CryptoNSNonce : NSObject {
	@private
	char bytes[CryptoNSNonceNonceLen];
}

- (id)initWithVal:(uint64_t)val;
- (id)initWithBytesAndLen:(char*)sBytes :(size_t)len;

- (NSString*)ccStr;
- (char*)data;
- (uint64_t)val;

@end
// -----------------------------------------------------------------------------
@interface CryptoNSMessage : NSObject {
	@private
	CryptoNSNonce* nonce;
	NSString* text;
}
@property (copy) CryptoNSNonce* nonce;
@property (copy) NSString* text;

- (id)initWithNonceBytesAndTextBytes:(char*)nonceBytes :(size_t)nonceLen :(char*)textBytes :(size_t)textLen;
- (id)initWithNonceAndText:(CryptoNSNonce*)sNonce :(NSString*)sText;
- (void)dealloc;

@end
// -----------------------------------------------------------------------------
#define CryptoNSSessionReceiveMTU 2048
@interface CryptoNSSession : NSObject {
	@private
	CryptoNSBase64Key* key;
	CryptoNSAlignedBuffer* ctxBuf;
	ae_ctx* ctx;
	uint64_t blocksEncrypted;
	
	CryptoNSAlignedBuffer* plaintextBuffer;
	CryptoNSAlignedBuffer* ciphertextBuffer;
	CryptoNSAlignedBuffer* nonceBuffer;
}

- (id)initWithBase64Key:(CryptoNSBase64Key*)sKey;
- (void)dealloc;

- (NSString*)encrypt:(CryptoNSMessage*)plaintext;
- (CryptoNSMessage*)decrypt:(NSString*)ciphertext;

// copy constructor
//- (id)initWithSession:(CryptoNSSession*)session;
// assignment operator
//- (id)assignment:(CryptoNSSession*)session;

@end
// -----------------------------------------------------------------------------
void cryptoNSDisableDumpingCore(void);
void cryptoNSReenableDumpingCore(void);
