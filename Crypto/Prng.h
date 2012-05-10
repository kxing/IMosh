//
//  PRNG.h
//  IMosh
//
//  Created by Kerry on 4/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>

#import "crypto.h"

static const char rdev[] = "/dev/urandom";

@interface CryptoNSPrng : NSObject {
	FILE* randfile;
}

// copy constructor
//- (id)initWithPrng;
// assignment operator
//- (id)assign:(CryptoNSPrng*)prng;

- (id)initWithDefault;
- (void)dealloc;

- (void)fill:(void*)dest :(size_t)size;
- (uint8_t)uint8;
- (uint32_t)uint32;
- (uint64_t)uint64;

@end
