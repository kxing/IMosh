//
//  PRNG.m
//  IMosh
//
//  Created by Kerry on 4/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Prng.h"

#include "cpp.h"

@implementation CryptoNSPrng

// copy constructor
//- (id)initWithPrng;
// assignment operator
//- (id)assign:(CryptoNSPrng*)prng;

- (id)initWithDefault {
	if (self = [super init]) {
		randfile =  fopen(rdev, "rb");
		if (randfile == NULL) {
			@throw [[[CryptoNSCryptoException alloc]
					 initWithText:[NSString stringWithFormat:@"%s: %s",
								   rdev, strerror(errno)]] autorelease];
		}
	}
	return self;
}

- (void)dealloc {
	if (0 != fclose(randfile)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:[NSString stringWithFormat:@"%s: %s",
							   rdev, strerror(errno)]] autorelease];
	}
	[super dealloc];
}

- (void)fill:(void*)dest :(size_t)size {
	if (0 == size) {
		return;
	}
	
	if (1 != fread(dest, size, 1, randfile)) {
		@throw [[[CryptoNSCryptoException alloc]
				 initWithText:[NSString stringWithFormat:@"Could not read from %s", rdev]] autorelease];
	}
}

- (uint8_t)uint8 {
	uint8_t x;
	[self fill:&x :1];
	return x;
}

- (uint32_t)uint32 {
	uint32_t x;
	[self fill:&x :4];
	return x;
}

- (uint64_t)uint64 {
	uint64_t x;
	[self fill:&x :8];
	return x;
}

@end
