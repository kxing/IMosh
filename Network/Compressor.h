//
//  Compressor.h
//  IMosh
//
//  Created by Kerry on 5/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NetworkNSCompressorBufferSize ((2048)*(2048))
@interface NetworkNSCompressor : NSObject {
	@private
	unsigned char* buffer;
}

- (id)init;
- (void)dealloc;

- (NSString*)compressStr:(NSString*)input;
- (NSString*)uncompressStr:(NSString*)input;

// copy constructor
//- (id)initWithCompressor:(NetworkNSCompressor*)compressor;
// assignment constructor
//- (id)assignment:(NetworkNSCompressor*)compressor;

@end
// -----------------------------------------------------------------------------
NetworkNSCompressor* getCompressor();
