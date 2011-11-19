//
//  Util.m
//  aware-client-ios
//
//  Created by Adam Watson on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "Util.h"

//class constants

//singleton shared instance
static Util *sharedInstance;


@implementation Util


#pragma mark Singleton Methods
+ (id)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}


#pragma mark Utility Methods


@end
