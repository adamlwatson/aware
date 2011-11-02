//
//  APIUtil.m
//  aware-client-ios
//
//  Created by Adam Watson on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "APIUtil.h"
#import "ASIHTTPRequest.h"

//singleton shared instance
static APIUtil *sharedInstance;

@implementation APIUtil

@synthesize someProp;


#pragma mark Singleton Methods
+ (id)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
- (id)init {
    if (self = [super init]) {
        someProp = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}


#pragma mark Utility Methods

- (id)createAPIRequestObject {
    NSURL *url = [NSURL URLWithString:@"https://adam-15:8000/locations"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    #ifdef DEBUG
        NSLog(@"** Disabling secure certificate validation in debug mode");
        [request setValidatesSecureCertificate:NO];
    #endif

    return request;
}

@end
