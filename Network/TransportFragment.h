//
//  TransportFragment.h
//  IMosh
//
//  Created by Kerry on 5/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportInstruction.pb.h"

#define NetworkNSHeaderLen 66

#define NetworkNSFragmentFragHeaderLen (sizeof(uint64_t)+sizeof(uint16_t))
@interface NetworkNSFragment : NSObject {
	@private
	uint64_t fragmentId;
	uint16_t fragmentNum;
	bool final;
	
	bool initialized;
	
	NSString* contents;
}
@property (assign) uint64_t fragmentId;
@property (assign) uint16_t fragmentNum;
@property (assign) bool final;
@property (assign) bool initialized;
@property (copy) NSString* contents;

- (id)initWithDefaults;
- (id)initWithIdFragmentNumFinalAndContents:(uint64_t)sId
										   :(uint16_t)sFragmentNum
										   :(bool)sFinal
										   :(NSString*)sContents;
- (id)initWithString:(NSString*)x;

- (NSString*)toString;

- (bool)equals:(NetworkNSFragment*)x;
@end
// -----------------------------------------------------------------------------
@interface NetworkNSFragmentAssembly : NSObject {
	@private
	NSMutableArray* fragments;
	uint64_t currentId;
	int fragmentsArrived;
	int fragmentsTotal;
}

- (id)initWithDefaults;
- (bool)addFragment:(NetworkNSFragment*)inst;
- (Instruction*)getAssembly;
@end
// -----------------------------------------------------------------------------
@interface NetworkNSFragmenter : NSObject {
	@private
	uint64_t nextInstructionId;
	Instruction* lastInstruction;
	int lastMtu;
}

- (id)initWithDefaults;
- (NSMutableArray*)makeFragments:(Instruction*)inst :(int)mtu;
- (uint64_t)lastAckSent;

@end
