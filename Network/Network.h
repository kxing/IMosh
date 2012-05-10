//
//  Network.h
//  IMosh
//
//  Created by Kerry on 4/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Crypto.h"

static const unsigned int MOSH_PROTOCOL_VERSION = 2;

uint64_t timestamp(void);
uint64_t timestamp16(void);
uint64_t timestampDiff(uint64_t tsNew, uint64_t tsOld);

// -----------------------------------------------------------------------------
typedef enum NetworkNSDirection {
	TO_SERVER = 0,
	TO_CLIENT = 1
} NetworkNSDirection;
// -----------------------------------------------------------------------------
@interface NetworkNSNetworkException : NSObject {
	@private
	NSString* function;
	int theErrno;
}
@property (copy) NSString* function;
@property (assign) int theErrno;

- (id)initWithFunctionAndErrno:(NSString*)sFunction :(int)sErrno;
@end
// -----------------------------------------------------------------------------
@interface NetworkNSPacket : NSObject {
	@private
	uint64_t seq;
	NetworkNSDirection direction;
	uint64_t timestamp;
	uint64_t timestampReply;
	NSString* payload;
}
@property (assign) uint64_t seq;
@property (assign) NetworkNSDirection direction;
@property (assign) uint64_t timestamp;
@property (assign) uint64_t timestampReply;
@property (copy) NSString* payload;

- (id)initWithSeqDirectionTimestampReplyAndPayload
		:(uint64_t)sSeq :(NetworkNSDirection)sDirection
		:(uint16_t)sTimestamp :(uint16_t)sTimestampReply
		:(NSString*)sPayload;

- (id)initWithCodedPacketAndSession:(NSString*)codedPacket :(CryptoNSSession*)session;
- (NSString*)toString:(CryptoNSSession*)session;

@end
// -----------------------------------------------------------------------------
#define NetworkNSConnectionSendMtu 1400
#define NetworkNSConnectionMinRto 50
#define NetworkNSConnectionMaxRto 1000

#define NetworkNSConnectionPortRangeLow 60001
#define NetworkNSConnectionPortRangeHigh 60999

@interface NetworkNSConnection: NSObject {
	@private
	
	int sock;
	bool hasRemoteAddr;
	struct sockaddr_in* remoteAddr;
	
	bool server;
	
	int mtu;
	
	CryptoNSBase64Key* key;
	CryptoNSSession* session;
	
	NetworkNSDirection direction;
	uint64_t nextSeq;
	uint16_t savedTimestamp;
	uint64_t savedTimestampReceivedAt;
	uint64_t expectedReceiverSeq;
	
	bool rttHit;
	double srtt;
	double rttVar;
}
+ (bool)tryBind:(int)socket :(uint32_t)sAddr :(int)port;
- (void)setup;
- (NetworkNSPacket*)newPacket:(NSString*) sPayload;

- (id)initWithDesiredIpAndDesiredPort:(char*)desiredIp :(char*)desiredPort;
- (id)initWithKeyStrIpAndPort:(char*)keyStr :(char*)ip :(int)port;
- (void)dealloc;

- (void)send:(NSString*)s;
- (NSString*)recv;
- (int)fd;
- (int)getMtu;

- (int)port;
- (NSString*)getKey;
- (bool)getHasRemoteAddr;

- (uint64_t)timeout;
- (double)getSrtt;

- (struct in_addr*)getRemoteIp;

@end


