//
//  TransportFragment.m
//  IMosh
//
//  Created by Kerry on 5/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "Byteorder.h"
#include "TransportInstruction.pb.h"
#include "Compressor.h"
#include "FatalAssert.h"
#import "TransportFragment.h"
#include "cpp.h"

static NSString* networkOrderString16(uint16_t hostOrder) {
	uint16_t netInt = htobe16(hostOrder);
	return stringFromCharPtrAndLength((char*)(&netInt), sizeof(netInt));
}

static NSString* networkOrderString64(uint64_t hostOrder) {
	uint64_t netInt = htobe64(hostOrder);
	return stringFromCharPtrAndLength((char*)(&netInt), sizeof(netInt));
}
// -----------------------------------------------------------------------------
@implementation NetworkNSFragment

@synthesize fragmentId;
@synthesize fragmentNum;
@synthesize final;
@synthesize initialized;
@synthesize contents;

- (id)initWithDefaults {
	if (self = [super init]) {
		fragmentId = -1;
		fragmentNum = -1;
		final = false;
		initialized = false;
		contents = @"";
	}
	return self;
}

- (id)initWithIdFragmentNumFinalAndContents:(uint64_t)sId
										   :(uint16_t)sFragmentNum
										   :(bool)sFinal
										   :(NSString*)sContents {
	if (self = [super init]) {
		fragmentId = sId;
		fragmentNum = sFragmentNum;
		final = sFinal;
		initialized = true;
		contents = sContents;
	}
	return self;
}

- (id)initWithString:(NSString*)x {
	if (self = [super init]) {
		initialized = true;
		
		const char* xChars = [x UTF8String];
		contents = stringFromCharPtrAndLength((char*)(xChars + NetworkNSFragmentFragHeaderLen),
											  [x length] - NetworkNSFragmentFragHeaderLen);
		
		NSAssert([x length] >= NetworkNSFragmentFragHeaderLen, @"Bad string length");
		
		uint64_t *data64 = (uint64_t*)(xChars);
		uint16_t *data16 = (uint16_t*)(xChars);
		fragmentId = be64toh(data64[0]);
		fragmentNum = be16toh(data16[4]);
		final = (fragmentNum & 0x8000) >> 15;
		fragmentNum &= 0x7FFF;
	}
	return self;
}

- (NSString*)toString {
	NSAssert(initialized, @"Not initialized");
	
	NSString* ret = networkOrderString64(fragmentId);
	
	fatal_assert(!( fragmentNum & 0x8000));
	uint16_t combinedFragmentNum = (final << 15) | fragmentNum;
	ret = [ret stringByAppendingString: networkOrderString16(combinedFragmentNum)];
	
	NSAssert([ret length] == NetworkNSFragmentFragHeaderLen, @"Bad header length");
	
	ret = [ret stringByAppendingString:contents];
	
	return ret;
}

- (bool)equals:(NetworkNSFragment*)x {
	return (fragmentId == [x fragmentId]) &&
			(fragmentNum == [x fragmentNum]) &&
			(final == [x final]) &&
			(initialized == [x initialized]) &&
			(contents == [x contents]);
}
@end
// -----------------------------------------------------------------------------
@implementation NetworkNSFragmentAssembly

- (id)initWithDefaults {
	if (self = [super init]) {
		fragments = [NSMutableArray arrayWithCapacity:0];
		currentId = -1;
		fragmentsArrived = 0;
		fragmentsTotal = -1;
	}
	return self;
}
	
- (bool)addFragment:(NetworkNSFragment*)frag {
	// TODO: fix this
	if (currentId != [frag fragmentId]) {
		[fragments removeAllObjects];
		for (int i = 0; i < [frag fragmentNum]; i++) {
			[fragments addObject:[NSNull null]];
		}
		[fragments addObject:frag];
		fragmentsArrived = 1;
		fragmentsTotal = -1;
		currentId = [frag fragmentId];
	} else {
		if ([fragments count] > [frag fragmentNum]
			&& [[fragments objectAtIndex:[frag fragmentNum]] initialized]) {
			NSAssert([fragments objectAtIndex:[frag fragmentNum]] == frag,
					 @"Failed to set fragment correctly");
		} else {
			while ((int)([fragments count]) < [frag fragmentNum] + 1) {
				[fragments addObject:[NSNull null]];
			}
			[fragments replaceObjectAtIndex:[frag fragmentNum] withObject:frag];
			fragmentsArrived++;
		}
	}
	
	if ([frag final]) {
		fragmentsTotal = [frag fragmentNum] + 1;
		NSAssert((int)([fragments count]) <= fragmentsTotal,
				 @"Inconsistent fragment data");
		while ((int)([fragments count]) < fragmentsTotal) {
			[fragments addObject:[NSNull null]];
		}
	}
	
	if (fragmentsTotal != -1) {
		NSAssert(fragmentsArrived <= fragmentsTotal,
				 @"Inconsistent fragment data");
	}
	
	return (fragmentsArrived == fragmentsTotal);
}
	
- (Instruction*)getAssembly {
	NSAssert(fragmentsArrived == fragmentsTotal, @"Not all fragments arrived");
	
	NSString* encoded = @"";
	
	for ( int i = 0; i < fragmentsTotal; i++ ) {
		NSAssert([[fragments objectAtIndex:i] initialized], @"Uninitialized fragment");
		encoded = [encoded stringByAppendingString:[[fragments objectAtIndex:i] contents]];
	}
	
	// TODO: test to see if this actually works
	NSData* data = [[getCompressor() uncompressStr: encoded] dataUsingEncoding:NSUTF8StringEncoding];
	Instruction* ret = [Instruction parseFromData:data];
	
	[fragments removeAllObjects];
	fragmentsArrived = 0;
	fragmentsTotal = -1;
	
	return ret;
}
@end
// -----------------------------------------------------------------------------
@implementation NetworkNSFragmenter

- (id)initWithDefaults {
	if (self = [super init]) {
		nextInstructionId = 0;
		lastInstruction = [[[[Instruction builder] setOldNum:-1] setNewNum:-1] build];
		lastMtu = -1;
	}
	return self;
}

- (NSMutableArray*)makeFragments:(Instruction*)inst :(int)mtu {
	if (([inst oldNum] != [lastInstruction oldNum])
		|| ([inst newNum] != [lastInstruction newNum])
		|| ([inst ackNum] != [lastInstruction ackNum])
		|| ([inst throwawayNum] != [lastInstruction throwawayNum])
		|| ([inst chaff] != [lastInstruction chaff])
		|| ([inst protocolVersion] != [lastInstruction protocolVersion])
		|| (lastMtu != mtu) ) {
		nextInstructionId++;
	}
	
	if (([inst oldNum] == [lastInstruction oldNum])
		&& ([inst newNum] == [lastInstruction newNum])) {
		NSAssert([inst diff] == [lastInstruction diff], @"Diffs are different");
	}
	
	lastInstruction = inst;
	lastMtu = mtu;
	
	// TODO: check to see if this actually works
	NSString* payload = [getCompressor() compressStr:[NSString stringWithUTF8String:[[inst data] bytes]]];
	uint16_t fragmentNum = 0;
	NSMutableArray* ret = [NSMutableArray arrayWithCapacity:0];
	
	while ([payload length] > 0) {
		NSString* thisFragment = nil;
		bool final = false;
		
		if ((int)([payload length] + NetworkNSHeaderLen) > mtu) {
			const char* payloadCharArray = [payload UTF8String];
			thisFragment = stringFromCharPtrAndLength((char*)(payloadCharArray), mtu - NetworkNSHeaderLen);
			payload = stringFromCharPtrAndLength((char*)(payloadCharArray) + mtu - NetworkNSHeaderLen,
												 [payload length] - mtu + NetworkNSHeaderLen);
		} else {
			thisFragment = payload;
			payload = @"";
			final = true;
		}
		
		NetworkNSFragment* newFragment = [[[NetworkNSFragment alloc] initWithIdFragmentNumFinalAndContents
										   :nextInstructionId
										   :fragmentNum++
										   :final
										   :thisFragment] autorelease];
		[ret addObject:newFragment];
	}
	
	return ret;
}

- (uint64_t)lastAckSent {
	return [lastInstruction ackNum];
}

@end
