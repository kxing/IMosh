//
//  Network.m
//  IMosh
//
//  Created by Kerry on 4/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "config.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <unistd.h>

/*
#if HAVE_CLOCK_GETTIME
  #include <time.h>
#elif HAVE_MACH_ABSOLUTE_TIME
  #include <mach/mach_time.h>
#elif HAVE_GETTIMEOFDAY
  #include <sys/time.h>
#endif
*/

#include "DosAssert.h"
#include "Byteorder.h"
#import "Network.h"
#import "Crypto.h"

#include "cpp.h"

#define DIRECTION_MASK ((uint64_t)(1)<<63)
#define SEQUENCE_MASK ((uint64_t)(-1)^(DIRECTION_MASK))

uint64_t timestamp(void) {
#if HAVE_CLOCK_GETTIME
	struct timespec tp;
	
	if (clock_gettime(CLOCK_MONOTONIC, &tp) < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno :@"clock_gettime" :errno] autorelease];
	}
	
	uint64_t millis = tp.tv_nsec / 1000000;
	millis += (uint64_t)(tp.tv_sec) * 1000;
	
	return millis;
#elif HAVE_MACH_ABSOLUTE_TIME
	static mach_timebase_info_data_t s_timebase_info;
	
	if (s_timebase_info.denom == 0) {
		mach_timebase_info(&s_timebase_info);
	}
	
	return ((mach_absolute_time() * s_timebase_info.numer) / (1000000 * s_timebase_info.denom));
#elif HAVE_GETTIMEOFDAY
	struct timeval tv;
	if (gettimeofday(&tv, NULL)) {
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno :@"gettimeofday" :errno] autorelease];
	}
	
	uint64_t millis = tv.tv_usec / 1000;
	millis += (uint64_t)(tv.tv_sec) * 1000;
	
	return millis;
#else
//# error "Don't know how to get a timestamp on this platform"
	NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
	return (uint64_t)(ts * 1000.0);
#endif
}

uint64_t timestamp16(void) {
	uint16_t ts = timestamp() % 65536;
	if (ts == (uint16_t)(-1)) {
		ts++;
	}
	return ts;
}
uint64_t timestampDiff(uint64_t tsNew, uint64_t tsOld) {
	int diff = tsNew - tsOld;
	if (diff < 0) {
		diff += 65536;
	}
	
	NSCAssert(diff >= 0, @"Diff less than zero");
	NSCAssert(diff <= 65535, @"Diff greater than 65535");
	
	return diff;
}

// -----------------------------------------------------------------------------
@implementation NetworkNSNetworkException

// getters and setters
@synthesize function;
@synthesize theErrno;

- (id)initWithFunctionAndErrno:(NSString*)sFunction :(int)sErrno {
	if (self = [super init]) {
		function = sFunction;
		theErrno = sErrno;
	}
	return self;
}

@end
// -----------------------------------------------------------------------------
@implementation NetworkNSPacket

// getters and setters
@synthesize seq;
@synthesize direction;
@synthesize timestamp;
@synthesize timestampReply;
@synthesize payload;

- (id)initWithSeqDirectionTimestampReplyAndPayload
		:(uint64_t)sSeq :(NetworkNSDirection)sDirection
		:(uint16_t)sTimestamp :(uint16_t)sTimestampReply
		:(NSString*)sPayload {
	if (self = [super init]) {
		seq = sSeq;
		direction = sDirection;
		timestamp = sTimestamp;
		timestampReply = sTimestampReply;
		payload = sPayload;
	}
	return self;
}

- (id)initWithCodedPacketAndSession:(NSString*)codedPacket :(CryptoNSSession*)session {
	if (self = [super init]) {
		CryptoNSMessage* message = [session decrypt:codedPacket];
		
		direction = ([[message nonce] val] & DIRECTION_MASK) ? TO_CLIENT : TO_SERVER;
		seq = [[message nonce] val] & SEQUENCE_MASK;
		
		dos_assert([[message text] length] >= 2 * sizeof(uint16_t));
		
		uint16_t* data = (uint16_t*)([[message text] UTF8String]);
		timestamp = be16toh(data[0]);
		timestampReply = be16toh(data[1]);
		
		const char* textCstring = [[message text] UTF8String];
		payload = stringFromCharPtrAndLength((char*)(textCstring) + 2 * sizeof(uint16_t),
											 (size_t)([[message text] length] - 2 * sizeof(uint16_t)));
	}
	return self;
}

- (NSString*)toString: (CryptoNSSession*)session {
	uint64_t direction_seq = ((uint64_t)(direction == TO_CLIENT) << 63) | (seq & SEQUENCE_MASK);
	
	uint16_t ts_net[2] = {htobe16(timestamp), htobe16(timestampReply)};
	
	NSString* timestamps = stringFromCharPtrAndLength((char*)ts_net, 2 * sizeof(uint16_t));
	
	CryptoNSNonce* nonce = [[[CryptoNSNonce alloc] initWithVal:direction_seq] autorelease];
	NSString* nonceText = [timestamps stringByAppendingString:payload];
	CryptoNSMessage* message = [[[CryptoNSMessage alloc] initWithNonceAndText :nonce :nonceText] autorelease];
	return [session encrypt:message];
}

@end
// -----------------------------------------------------------------------------
@implementation NetworkNSConnection

+ (bool)tryBind:(int)socket :(uint32_t)sAddr :(int)port {
	struct sockaddr_in localAddr;
	localAddr.sin_family = AF_INET;
	localAddr.sin_addr.s_addr = sAddr;
	
	int searchLow = NetworkNSConnectionPortRangeLow;
	int searchHigh = NetworkNSConnectionPortRangeHigh;
	
	if (port != 0) {
		searchLow = port;
		searchHigh = port;
	}
	
	for (int i = searchLow; i <= searchHigh; i++) {
		localAddr.sin_port = htons(i);
		
		if (bind(socket, (struct sockaddr*)(&localAddr), sizeof(localAddr)) == 0) {
			return true;
		} else if (i == searchHigh) {
			fprintf(stderr, "Failed binding to %s:%d\n",
					inet_ntoa(localAddr.sin_addr),
					ntohs(localAddr.sin_port));
			@throw [[[NetworkNSNetworkException alloc]
					initWithFunctionAndErrno:@"bind" :errno] autorelease];
		}
	}
	
	NSCAssert(false, @"Error in code");
	return false;
}

- (void)setup {
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno:@"socket" :errno] autorelease];
	}
	
#ifdef HAVE_IP_MTU_DISCOVER
	char flag = IP_PMTUDISC_DONT;
	socklen_t optlen = sizeof(flag);
	if (setsockopt(sock, IPPROTO_IP, IP_MTU_DISCOVER, &flag, optlen) < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno:@"setsockopt" :errno] autorelease];
	}
#endif
}

- (NetworkNSPacket*)newPacket:(NSString*) sPayload {
	uint16_t outgoing_timestamp_reply = -1;
	
	uint64_t now = timestamp();
	
	if (now - savedTimestampReceivedAt < 1000) {
		outgoing_timestamp_reply = savedTimestamp + (now - savedTimestampReceivedAt);
		savedTimestamp = -1;
		savedTimestampReceivedAt = 0;
	}
	
	NetworkNSPacket* p = [[[NetworkNSPacket alloc] initWithSeqDirectionTimestampReplyAndPayload
			:nextSeq :direction :timestamp16() :outgoing_timestamp_reply :sPayload] autorelease];
	nextSeq++;
	return p;
}

- (id)initWithDesiredIpAndDesiredPort:(char*)desiredIp :(char*)desiredPort {
	if (self = [super init]) {
		sock = -1;
		hasRemoteAddr = false;
		remoteAddr = malloc(sizeof(remoteAddr));
		server = true;
		mtu = NetworkNSConnectionSendMtu;
		key = [[CryptoNSBase64Key alloc] initWithRandomKey];
		session = [[CryptoNSSession alloc] initWithBase64Key:key];
		direction = TO_CLIENT;
		nextSeq = 0;
		savedTimestamp = -1;
		savedTimestampReceivedAt = 0;
		expectedReceiverSeq = 0;
		rttHit = false;
		srtt = 1000;
		rttVar = 500;
		
		[self setup];
		long int desiredPortNo = 0;
		
		if (desiredPort) {
			char *end;
			errno = 0;
			desiredPortNo = strtol(desiredPort, &end, 10);
			if ((errno != 0) || (end != desiredPort + strlen(desiredPort))) {
				@throw [[[NetworkNSNetworkException alloc]
						 initWithFunctionAndErrno:@"Invalid port nmber" :errno] autorelease];
			}
		}
		
		if ((desiredPortNo < 0) || (desiredPortNo > 65535)) {
			@throw [[[NetworkNSNetworkException alloc]
					 initWithFunctionAndErrno:@"Port number outside valid range [0..65535" :0] autorelease];
		}
		
		/* convert desired IP */
		uint32_t desiredIpAddr = INADDR_ANY;
		
		if (desiredIp) {
			struct in_addr sinAddr;
			if (inet_aton(desiredIp, &sinAddr) == 0 ) {
				@throw [[[NetworkNSNetworkException alloc]
						 initWithFunctionAndErrno:@"Invalid IP address" :errno] autorelease];
			}
			desiredIpAddr = sinAddr.s_addr;
		}
		
		/* try to bind to desired IP first */
		if (desiredIpAddr != INADDR_ANY) {
			@try {
				if ([NetworkNSConnection tryBind:sock :desiredIpAddr :desiredPortNo]) {
					return self;
				}
			} @catch (NetworkNSNetworkException* e) {
				struct in_addr sinAddr;
				sinAddr.s_addr = desiredIpAddr;
				fprintf(stderr, "Error binding to IP %s: %s: %s\n",
						inet_ntoa(sinAddr),
						[[e function] UTF8String], strerror([e theErrno]));
			}
		}
		
		@try {
			if ([NetworkNSConnection tryBind :sock :INADDR_ANY :desiredPortNo]) {
				return self;
			}
		} @catch (NetworkNSNetworkException* e) {
			fprintf(stderr, "Error binding to any interface: %s: %s\n",
					[[e function] UTF8String], strerror([e theErrno]));
			@throw e; /* this time it's fatal */
		}
		
		NSAssert(false, @"Failed to bind");
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno:@"Could not bind" :errno] autorelease];
	}
	return self;
}

- (id)initWithKeyStrIpAndPort:(char*)keyStr :(char*)ip :(int)port {
	if (self = [super init]) {
		sock = -1;
		hasRemoteAddr = false;
		remoteAddr = malloc(sizeof(remoteAddr));
		server = false;
		mtu = NetworkNSConnectionSendMtu;
		key = [[CryptoNSBase64Key alloc] initWithPrintableKey:[NSString stringWithCString:keyStr]];
		session = [[CryptoNSSession alloc] initWithBase64Key:key];
		direction = TO_SERVER;
		nextSeq = 0;
		savedTimestamp = -1;
		savedTimestampReceivedAt = 0;
		expectedReceiverSeq = 0;
		rttHit = false;
		srtt = 1000;
		rttVar = 500;
		
		[self setup];
		
		remoteAddr->sin_family = AF_INET;
		remoteAddr->sin_port = htons(port);
		if (!inet_aton(ip, &(remoteAddr->sin_addr))) {
			int savedErrno = errno;
			char buffer[2048];
			snprintf(buffer, 2048, "Bad IP address (%s)", ip);
			@throw [[[NetworkNSNetworkException alloc]
					initWithFunctionAndErrno:[NSString stringWithCString:buffer] :savedErrno] autorelease];
		}
		
		hasRemoteAddr = true;
	}
	return self;
}

- (void)dealloc {
	[session release];
	[key release];
	free(remoteAddr);
	
	if (close(sock) < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				 initWithFunctionAndErrno:@"close" :errno] autorelease];
	}
	[super dealloc];
}

- (void)send:(NSString*)s {
	NSAssert(hasRemoteAddr, @"No remote address");
	
	NetworkNSPacket* px = [self newPacket:s];
	
	NSString* p = [px toString:session];
	
	ssize_t bytesSent = sendto(sock, [p UTF8String], [p length], 0,
								(struct sockaddr*)&remoteAddr, sizeof(remoteAddr));
	
	if ((!server) && (bytesSent != (ssize_t)([p length]))) {
		@throw [[[NetworkNSNetworkException alloc]
				initWithFunctionAndErrno:@"sendto" :errno] autorelease];
	}
}

- (NSString*)recv {
	struct sockaddr_in packetRemoteAddr;
	
	char buf[CryptoNSSessionReceiveMTU];
	
	socklen_t addrlen = sizeof(packetRemoteAddr);
	
	ssize_t receivedLen = recvfrom(sock,
									buf,
									CryptoNSSessionReceiveMTU,
									0,
									(struct sockaddr*)(&packetRemoteAddr),
									&addrlen);
	
	if (receivedLen < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				initWithFunctionAndErrno:@"recvfrom" :errno] autorelease];
	}
	
	if (receivedLen > CryptoNSSessionReceiveMTU) {
		char buffer[2048];
		snprintf(buffer, 2048, "Received oversize datagram (size %d) and limit is %d\n",
				 (int)(receivedLen), CryptoNSSessionReceiveMTU);
		@throw [[[NetworkNSNetworkException alloc]
				initWithFunctionAndErrno:[NSString stringWithCString:buffer] :errno] autorelease];
	}
	
	NetworkNSPacket* p = [[NetworkNSPacket alloc]
						  initWithCodedPacketAndSession:(stringFromCharPtrAndLength(buf, receivedLen)) :session];
	
	dos_assert([p direction] == (server ? TO_SERVER : TO_CLIENT));
	
	if ([p seq] >= expectedReceiverSeq) {
		expectedReceiverSeq = [p seq] + 1;
		
		if ([p timestamp] != (uint16_t)(-1)) {
			savedTimestamp = [p timestamp];
			savedTimestampReceivedAt = timestamp();
		}
		
		if ([p timestampReply] != (uint16_t)(-1) ) {
			uint16_t now = timestamp16();
			double r = timestampDiff(now, [p timestampReply]);
			
			if (r < 5000) {
				if (!rttHit) {
					srtt = r;
					rttVar = r / 2;
					rttHit = true;
				} else {
					const double alpha = 1.0 / 8.0;
					const double beta = 1.0 / 4.0;
					
					rttVar = (1 - beta) * rttVar + (beta * fabs(srtt - r));
					srtt = (1 - alpha) * srtt + (alpha * r);
				}
			}
		}
		
		hasRemoteAddr = true;
		
		if (server) {
			if ((remoteAddr->sin_addr.s_addr != packetRemoteAddr.sin_addr.s_addr)
				|| (remoteAddr->sin_port != packetRemoteAddr.sin_port)) {
				memcpy(remoteAddr, &packetRemoteAddr, sizeof(struct sockaddr_in));
				fprintf(stderr, "Server now attached to client at %s:%d\n",
						inet_ntoa(remoteAddr->sin_addr),
						ntohs(remoteAddr->sin_port));
			}
		}
	}
	
	return [p payload];
}

- (int)fd {
	return sock;
}

- (int)getMtu {
	return mtu;
}

- (int)port {
	struct sockaddr_in localAddr;
	socklen_t addrlen = sizeof(localAddr);
	
	if (getsockname(sock, (struct sockaddr*)(&localAddr), &addrlen) < 0) {
		@throw [[[NetworkNSNetworkException alloc]
				initWithFunctionAndErrno:@"getsockname" :errno] autorelease];
	}
	
	return ntohs(localAddr.sin_port);
}

- (NSString*)getKey {
	return [key printableKey];
}

- (bool)getHasRemoteAddr {
	return hasRemoteAddr;
}

- (uint64_t)timeout {
	uint64_t rto = lrint(ceil(srtt + 4 * rttVar));
	if (rto < NetworkNSConnectionMinRto) {
		rto = NetworkNSConnectionMinRto;
	} else if (rto > NetworkNSConnectionMaxRto) {
		rto = NetworkNSConnectionMaxRto;
	}
	return rto;
}

- (double)getSrtt {
	return srtt;
}

- (struct in_addr*)getRemoteIp {
	return &(remoteAddr->sin_addr);
}

@end
