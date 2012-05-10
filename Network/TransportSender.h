//
//  TransportSender.h
//  IMosh
//
//  Created by Kerry on 5/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "network.h"
#import "TransportInstruction.pb.h"
#import "TransportState.h"
#import "TransportFragment.h"
#import "PRNG.h"

#define NetworkNSSendIntervalMin 20
#define NetworkNSSendIntervalMax 250
#define NetworkNSAckInterval 3000
#define NetworkNSAckDelay 100
#define NetworkNSShutdownRetries 16
#define NetworkNSActiveRetryTimeout 10000
	
@interface NetworkNSTransportSender : NSObject {
	@private
	NetworkNSConnection* connection;
	id current_state;
	
	NSMutableArray* sent_states;
	NSEnumerator* assumed_receiver_state;
	NetworkNSFragmenter* fragmenter;
	
	uint64_t next_ack_time;
	uint64_t next_send_time;
		
	bool verbose;
	bool shutdown_in_progress;
	int shutdown_tries;
	
	uint64_t ack_num;
	bool pending_data_ack;
	
	unsigned int SEND_MINDELAY;
	
	uint64_t last_heard;
	
	CryptoNSPrng* prng;
	
	uint64_t mindelay_clock;
}

// private methods
- (void)updateAssumedReceiverState;
- (void)attemptProspectiveResendOptimization:(NSString*)proposedDiff;
- (void)rationalizeStates;
- (void)sendToReceiver:(NSString*)diff;
- (void)sendEmptyAck;
- (void)sendInFragments:(NSString*)diff :(uint64_t)new_num;
- (void)addSentState:(uint64_t)the_timestamp :(uint64_t)num :(id)state;

- (NSString*)makeChaff;
- (void)calculateTimers;
			
// public methods
- (id)initWithConnectionAndState:(NetworkNSConnection*)s_connection :(id)initial_state;
- (void)tick;
- (int)waitTime;
- (void)processAcknowledgmentThrough:(uint64_t)ack_num;
- (void)setAckNum:(uint64_t)s_ack_num;
- (void)setDataAck;
- (void)remoteHeard:(uint64_t)ts;
- (void)startShutdown;
- (id)getCurrentState;
- (void)setCurrentState:(id)x;
- (void)setVerbose;
			
- (bool)getShutdownInProgress;
- (bool)getShutdownAcknowledged;
- (bool)getCounterpartyShutdownAcknowledged;
- (uint64_t)getSentStateAckedTimestamp;
- (uint64_t)getSentStateAcked;
- (uint64_t)getSentStateLast;
			
- (bool)shutdownAckTimedOut;
			
- (void)setSendDelay:(int)new_delay;
			
- (unsigned int)sendInterval;

// copy constructor
- (id)initWithTransportSender:(NetworkNSTransportSender*)x;
// assignment operator
- (NetworkNSTransportSender*)assign:(NetworkNSTransportSender*)x;

@end
