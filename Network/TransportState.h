/*
 *  TransportState.h
 *  IMosh
 *
 *  Created by Kerry on 5/4/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

@interface NetworkNSTimestampedState : NSObject {
	@private
	uint64_t timestamp;
	uint64_t num;
	id state;
}
@property (assign) uint64_t timestamp;
@property (assign) uint64_t num;
@property (copy) id state;

- (id)initWithTimestampNumAndState:(uint64_t)sTimestamp :(uint64_t)sNum :(id)sState;

- (bool)numEq:(uint64_t)v;
- (bool)numLt:(uint64_t)v;

@end
