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

@synthesize urlPrefix;


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
        
        #ifdef DEBUG
            urlPrefix = [[NSString alloc] initWithString:@"https://adam-15:8000"];
            NSLog(@"DEBUG MODE: %@", urlPrefix);
        #else
            urlPrefix = [[NSString alloc] initWithString:@"https://prod:8000"];
        #endif 
    }
    return self;
}


#pragma mark Utility Methods
- (id)createAPIRequestWithURI:(NSString *)uri {
    
    NSString *apiUrl =[NSString stringWithFormat:@"%@%@", urlPrefix, uri]; 
    NSURL *url = [NSURL URLWithString:apiUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    #ifdef DEBUG
        NSLog(@"** Disabling secure certificate validation in debug mode");
        [request setValidatesSecureCertificate:NO];
    #endif

    return request;
}

@end
