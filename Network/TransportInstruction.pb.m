// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "TransportInstruction.pb.h"

@implementation TransportInstructionRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [TransportInstructionRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface Instruction ()
@property int32_t protocolVersion;
@property int64_t oldNum;
@property int64_t newNum;
@property int64_t ackNum;
@property int64_t throwawayNum;
@property (retain) NSData* diff;
@property (retain) NSData* chaff;
@end

@implementation Instruction

- (BOOL) hasProtocolVersion {
  return !!hasProtocolVersion_;
}
- (void) setHasProtocolVersion:(BOOL) value {
  hasProtocolVersion_ = !!value;
}
@synthesize protocolVersion;
- (BOOL) hasOldNum {
  return !!hasOldNum_;
}
- (void) setHasOldNum:(BOOL) value {
  hasOldNum_ = !!value;
}
@synthesize oldNum;
- (BOOL) hasNewNum {
  return !!hasNewNum_;
}
- (void) setHasNewNum:(BOOL) value {
  hasNewNum_ = !!value;
}
@synthesize newNum;
- (BOOL) hasAckNum {
  return !!hasAckNum_;
}
- (void) setHasAckNum:(BOOL) value {
  hasAckNum_ = !!value;
}
@synthesize ackNum;
- (BOOL) hasThrowawayNum {
  return !!hasThrowawayNum_;
}
- (void) setHasThrowawayNum:(BOOL) value {
  hasThrowawayNum_ = !!value;
}
@synthesize throwawayNum;
- (BOOL) hasDiff {
  return !!hasDiff_;
}
- (void) setHasDiff:(BOOL) value {
  hasDiff_ = !!value;
}
@synthesize diff;
- (BOOL) hasChaff {
  return !!hasChaff_;
}
- (void) setHasChaff:(BOOL) value {
  hasChaff_ = !!value;
}
@synthesize chaff;
- (void) dealloc {
  self.diff = nil;
  self.chaff = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.protocolVersion = 0;
    self.oldNum = 0L;
    self.newNum = 0L;
    self.ackNum = 0L;
    self.throwawayNum = 0L;
    self.diff = [NSData data];
    self.chaff = [NSData data];
  }
  return self;
}
static Instruction* defaultInstructionInstance = nil;
+ (void) initialize {
  if (self == [Instruction class]) {
    defaultInstructionInstance = [[Instruction alloc] init];
  }
}
+ (Instruction*) defaultInstance {
  return defaultInstructionInstance;
}
- (Instruction*) defaultInstance {
  return defaultInstructionInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasProtocolVersion) {
    [output writeUInt32:1 value:self.protocolVersion];
  }
  if (self.hasOldNum) {
    [output writeUInt64:2 value:self.oldNum];
  }
  if (self.hasNewNum) {
    [output writeUInt64:3 value:self.newNum];
  }
  if (self.hasAckNum) {
    [output writeUInt64:4 value:self.ackNum];
  }
  if (self.hasThrowawayNum) {
    [output writeUInt64:5 value:self.throwawayNum];
  }
  if (self.hasDiff) {
    [output writeData:6 value:self.diff];
  }
  if (self.hasChaff) {
    [output writeData:7 value:self.chaff];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size = memoizedSerializedSize;
  if (size != -1) {
    return size;
  }

  size = 0;
  if (self.hasProtocolVersion) {
    size += computeUInt32Size(1, self.protocolVersion);
  }
  if (self.hasOldNum) {
    size += computeUInt64Size(2, self.oldNum);
  }
  if (self.hasNewNum) {
    size += computeUInt64Size(3, self.newNum);
  }
  if (self.hasAckNum) {
    size += computeUInt64Size(4, self.ackNum);
  }
  if (self.hasThrowawayNum) {
    size += computeUInt64Size(5, self.throwawayNum);
  }
  if (self.hasDiff) {
    size += computeDataSize(6, self.diff);
  }
  if (self.hasChaff) {
    size += computeDataSize(7, self.chaff);
  }
  size += self.unknownFields.serializedSize;
  memoizedSerializedSize = size;
  return size;
}
+ (Instruction*) parseFromData:(NSData*) data {
  return (Instruction*)[[[Instruction builder] mergeFromData:data] build];
}
+ (Instruction*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (Instruction*)[[[Instruction builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (Instruction*) parseFromInputStream:(NSInputStream*) input {
  return (Instruction*)[[[Instruction builder] mergeFromInputStream:input] build];
}
+ (Instruction*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (Instruction*)[[[Instruction builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (Instruction*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (Instruction*)[[[Instruction builder] mergeFromCodedInputStream:input] build];
}
+ (Instruction*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (Instruction*)[[[Instruction builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (Instruction_Builder*) builder {
  return [[[Instruction_Builder alloc] init] autorelease];
}
+ (Instruction_Builder*) builderWithPrototype:(Instruction*) prototype {
  return [[Instruction builder] mergeFrom:prototype];
}
- (Instruction_Builder*) builder {
  return [Instruction builder];
}
@end

@interface Instruction_Builder()
@property (retain) Instruction* result;
@end

@implementation Instruction_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[Instruction alloc] init] autorelease];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (Instruction_Builder*) clear {
  self.result = [[[Instruction alloc] init] autorelease];
  return self;
}
- (Instruction_Builder*) clone {
  return [Instruction builderWithPrototype:result];
}
- (Instruction*) defaultInstance {
  return [Instruction defaultInstance];
}
- (Instruction*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (Instruction*) buildPartial {
  Instruction* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (Instruction_Builder*) mergeFrom:(Instruction*) other {
  if (other == [Instruction defaultInstance]) {
    return self;
  }
  if (other.hasProtocolVersion) {
    [self setProtocolVersion:other.protocolVersion];
  }
  if (other.hasOldNum) {
    [self setOldNum:other.oldNum];
  }
  if (other.hasNewNum) {
    [self setNewNum:other.newNum];
  }
  if (other.hasAckNum) {
    [self setAckNum:other.ackNum];
  }
  if (other.hasThrowawayNum) {
    [self setThrowawayNum:other.throwawayNum];
  }
  if (other.hasDiff) {
    [self setDiff:other.diff];
  }
  if (other.hasChaff) {
    [self setChaff:other.chaff];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (Instruction_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (Instruction_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSet_Builder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setProtocolVersion:[input readUInt32]];
        break;
      }
      case 16: {
        [self setOldNum:[input readUInt64]];
        break;
      }
      case 24: {
        [self setNewNum:[input readUInt64]];
        break;
      }
      case 32: {
        [self setAckNum:[input readUInt64]];
        break;
      }
      case 40: {
        [self setThrowawayNum:[input readUInt64]];
        break;
      }
      case 50: {
        [self setDiff:[input readData]];
        break;
      }
      case 58: {
        [self setChaff:[input readData]];
        break;
      }
    }
  }
}
- (BOOL) hasProtocolVersion {
  return result.hasProtocolVersion;
}
- (int32_t) protocolVersion {
  return result.protocolVersion;
}
- (Instruction_Builder*) setProtocolVersion:(int32_t) value {
  result.hasProtocolVersion = YES;
  result.protocolVersion = value;
  return self;
}
- (Instruction_Builder*) clearProtocolVersion {
  result.hasProtocolVersion = NO;
  result.protocolVersion = 0;
  return self;
}
- (BOOL) hasOldNum {
  return result.hasOldNum;
}
- (int64_t) oldNum {
  return result.oldNum;
}
- (Instruction_Builder*) setOldNum:(int64_t) value {
  result.hasOldNum = YES;
  result.oldNum = value;
  return self;
}
- (Instruction_Builder*) clearOldNum {
  result.hasOldNum = NO;
  result.oldNum = 0L;
  return self;
}
- (BOOL) hasNewNum {
  return result.hasNewNum;
}
- (int64_t) newNum {
  return result.newNum;
}
- (Instruction_Builder*) setNewNum:(int64_t) value {
  result.hasNewNum = YES;
  result.newNum = value;
  return self;
}
- (Instruction_Builder*) clearNewNum {
  result.hasNewNum = NO;
  result.newNum = 0L;
  return self;
}
- (BOOL) hasAckNum {
  return result.hasAckNum;
}
- (int64_t) ackNum {
  return result.ackNum;
}
- (Instruction_Builder*) setAckNum:(int64_t) value {
  result.hasAckNum = YES;
  result.ackNum = value;
  return self;
}
- (Instruction_Builder*) clearAckNum {
  result.hasAckNum = NO;
  result.ackNum = 0L;
  return self;
}
- (BOOL) hasThrowawayNum {
  return result.hasThrowawayNum;
}
- (int64_t) throwawayNum {
  return result.throwawayNum;
}
- (Instruction_Builder*) setThrowawayNum:(int64_t) value {
  result.hasThrowawayNum = YES;
  result.throwawayNum = value;
  return self;
}
- (Instruction_Builder*) clearThrowawayNum {
  result.hasThrowawayNum = NO;
  result.throwawayNum = 0L;
  return self;
}
- (BOOL) hasDiff {
  return result.hasDiff;
}
- (NSData*) diff {
  return result.diff;
}
- (Instruction_Builder*) setDiff:(NSData*) value {
  result.hasDiff = YES;
  result.diff = value;
  return self;
}
- (Instruction_Builder*) clearDiff {
  result.hasDiff = NO;
  result.diff = [NSData data];
  return self;
}
- (BOOL) hasChaff {
  return result.hasChaff;
}
- (NSData*) chaff {
  return result.chaff;
}
- (Instruction_Builder*) setChaff:(NSData*) value {
  result.hasChaff = YES;
  result.chaff = value;
  return self;
}
- (Instruction_Builder*) clearChaff {
  result.hasChaff = NO;
  result.chaff = [NSData data];
  return self;
}
@end
