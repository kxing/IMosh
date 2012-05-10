//
//  IMoshAppDelegate.m
//  IMosh
//
//  Created by Kerry on 4/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "IMoshAppDelegate.h"

@implementation IMoshAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
