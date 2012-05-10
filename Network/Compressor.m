//
//  Compressor.m
//  IMosh
//
//  Created by Kerry on 5/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include <zlib.h>

#import "Compressor.h"
#include "DosAssert.h"

#include "cpp.h"

@implementation NetworkNSCompressor
- (id)init {
	if (self = [super init]) {
		buffer = malloc(NetworkNSCompressorBufferSize);
	}
	return self;
}

- (void)dealloc {
	if (buffer) {
		free(buffer);
	}
	[super dealloc];
}

- (NSString*)compressStr:(NSString*)input {
	long unsigned int len = NetworkNSCompressorBufferSize;
	dos_assert(Z_OK == compress(buffer, &len,
								(const unsigned char*)([input UTF8String]),
								[input length]));
	return stringFromCharPtrAndLength((char*)(buffer), len);
}

- (NSString*)uncompressStr:(NSString*)input {
	long unsigned int len = NetworkNSCompressorBufferSize;
	dos_assert(Z_OK == uncompress(buffer, &len,
								  (const unsigned char*)([input UTF8String]),
								  [input length]));
	return stringFromCharPtrAndLength((char*)(buffer), len);
}

@end
// -----------------------------------------------------------------------------
NetworkNSCompressor* getCompressor() {
	static NetworkNSCompressor* theCompressor;
	return theCompressor;
}
