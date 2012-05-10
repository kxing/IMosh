//
//  TransportState.m
//  IMosh
//
//  Created by Kerry on 5/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TransportState.h"

@implementation NetworkNSTimestampedState

@synthesize timestamp;
@synthesize num;
@synthesize state;

- (id)initWithTimestampNumAndState:(uint64_t)sTimestamp :(uint64_t)sNum :(id)sState {
	if (self = [super init]) {
		timestamp = sTimestamp;
		num = sNum;
		state = sState;
	}
	return self;
}

- (bool)numEq:(uint64_t)v {
	return num == v;
}

- (bool)numLt:(uint64_t)v {
	return num < v;
}

@end
