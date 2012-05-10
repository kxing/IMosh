/*
 *  cpp.h
 *  IMosh
 *
 *  Created by Kerry on 4/26/12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef CPP_HPP
#define CPP_HPP

void badAlloc() {
	@throw([NSException exceptionWithName:@"BadAllocException" reason:@"Bad alloc" userInfo:nil]);
}

NSString* stringFromCharPtrAndLength(char* ptr, size_t len) {
	char chars[len];
	memcpy(chars, ptr, len);
	return [NSString stringWithCString:chars];
}

uint64_t max(uint64_t a, uint64_t b) {
	if (a >= b) {
		return a;
	} else {
		return b;
	}
}
#endif
