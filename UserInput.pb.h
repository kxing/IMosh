// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class Instruction;
@class Instruction_Builder;
@class Keystroke;
@class Keystroke_Builder;
@class ResizeMessage;
@class ResizeMessage_Builder;
@class UserMessage;
@class UserMessage_Builder;

@interface UserInputRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
+ (id<PBExtensionField>) keystroke;
+ (id<PBExtensionField>) resize;
@end

@interface UserMessage : PBGeneratedMessage {
@private
  NSMutableArray* mutableInstructionList;
}
- (NSArray*) instructionList;
- (Instruction*) instructionAtIndex:(int32_t) index;

+ (UserMessage*) defaultInstance;
- (UserMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserMessage_Builder*) builder;
+ (UserMessage_Builder*) builder;
+ (UserMessage_Builder*) builderWithPrototype:(UserMessage*) prototype;

+ (UserMessage*) parseFromData:(NSData*) data;
+ (UserMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMessage*) parseFromInputStream:(NSInputStream*) input;
+ (UserMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserMessage_Builder : PBGeneratedMessage_Builder {
@private
  UserMessage* result;
}

- (UserMessage*) defaultInstance;

- (UserMessage_Builder*) clear;
- (UserMessage_Builder*) clone;

- (UserMessage*) build;
- (UserMessage*) buildPartial;

- (UserMessage_Builder*) mergeFrom:(UserMessage*) other;
- (UserMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSArray*) instructionList;
- (Instruction*) instructionAtIndex:(int32_t) index;
- (UserMessage_Builder*) replaceInstructionAtIndex:(int32_t) index with:(Instruction*) value;
- (UserMessage_Builder*) addInstruction:(Instruction*) value;
- (UserMessage_Builder*) addAllInstruction:(NSArray*) values;
- (UserMessage_Builder*) clearInstructionList;
@end

@interface Instruction : PBExtendableMessage {
@private
}

+ (Instruction*) defaultInstance;
- (Instruction*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (Instruction_Builder*) builder;
+ (Instruction_Builder*) builder;
+ (Instruction_Builder*) builderWithPrototype:(Instruction*) prototype;

+ (Instruction*) parseFromData:(NSData*) data;
+ (Instruction*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Instruction*) parseFromInputStream:(NSInputStream*) input;
+ (Instruction*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Instruction*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (Instruction*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface Instruction_Builder : PBExtendableMessage_Builder {
@private
  Instruction* result;
}

- (Instruction*) defaultInstance;

- (Instruction_Builder*) clear;
- (Instruction_Builder*) clone;

- (Instruction*) build;
- (Instruction*) buildPartial;

- (Instruction_Builder*) mergeFrom:(Instruction*) other;
- (Instruction_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (Instruction_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface Keystroke : PBGeneratedMessage {
@private
  BOOL hasKeys_:1;
  NSData* keys;
}
- (BOOL) hasKeys;
@property (readonly, retain) NSData* keys;

+ (Keystroke*) defaultInstance;
- (Keystroke*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (Keystroke_Builder*) builder;
+ (Keystroke_Builder*) builder;
+ (Keystroke_Builder*) builderWithPrototype:(Keystroke*) prototype;

+ (Keystroke*) parseFromData:(NSData*) data;
+ (Keystroke*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Keystroke*) parseFromInputStream:(NSInputStream*) input;
+ (Keystroke*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Keystroke*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (Keystroke*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface Keystroke_Builder : PBGeneratedMessage_Builder {
@private
  Keystroke* result;
}

- (Keystroke*) defaultInstance;

- (Keystroke_Builder*) clear;
- (Keystroke_Builder*) clone;

- (Keystroke*) build;
- (Keystroke*) buildPartial;

- (Keystroke_Builder*) mergeFrom:(Keystroke*) other;
- (Keystroke_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (Keystroke_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasKeys;
- (NSData*) keys;
- (Keystroke_Builder*) setKeys:(NSData*) value;
- (Keystroke_Builder*) clearKeys;
@end

@interface ResizeMessage : PBGeneratedMessage {
@private
  BOOL hasWidth_:1;
  BOOL hasHeight_:1;
  int32_t width;
  int32_t height;
}
- (BOOL) hasWidth;
- (BOOL) hasHeight;
@property (readonly) int32_t width;
@property (readonly) int32_t height;

+ (ResizeMessage*) defaultInstance;
- (ResizeMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResizeMessage_Builder*) builder;
+ (ResizeMessage_Builder*) builder;
+ (ResizeMessage_Builder*) builderWithPrototype:(ResizeMessage*) prototype;

+ (ResizeMessage*) parseFromData:(NSData*) data;
+ (ResizeMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResizeMessage*) parseFromInputStream:(NSInputStream*) input;
+ (ResizeMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResizeMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResizeMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResizeMessage_Builder : PBGeneratedMessage_Builder {
@private
  ResizeMessage* result;
}

- (ResizeMessage*) defaultInstance;

- (ResizeMessage_Builder*) clear;
- (ResizeMessage_Builder*) clone;

- (ResizeMessage*) build;
- (ResizeMessage*) buildPartial;

- (ResizeMessage_Builder*) mergeFrom:(ResizeMessage*) other;
- (ResizeMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResizeMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasWidth;
- (int32_t) width;
- (ResizeMessage_Builder*) setWidth:(int32_t) value;
- (ResizeMessage_Builder*) clearWidth;

- (BOOL) hasHeight;
- (int32_t) height;
- (ResizeMessage_Builder*) setHeight:(int32_t) value;
- (ResizeMessage_Builder*) clearHeight;
@end

