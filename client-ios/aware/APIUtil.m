//
//  APIUtil.m
//  aware-client-ios
//
//  Created by Adam Watson on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "APIUtil.h"
#import "ASIHTTPRequest.h"


//class constants
#ifdef DEBUG
    NSString const *kApiUrlPrefix = @"https://adam-15:8000";
#else
    NSString const *kApiUrlPrefix = @"https://some.prod.server5:8000";
#endif

//singleton shared instance
static APIUtil *sharedInstance;


@implementation APIUtil


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

    }
    return self;
}


#pragma mark Utility Methods
- (id)createAPIRequestWithURI:(NSString *)uri {
    
    NSString *apiUrl =[NSString stringWithFormat:@"%@%@", kApiUrlPrefix, uri]; 
    NSURL *url = [NSURL URLWithString:apiUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    #ifdef DEBUG
        NSLog(@"** Disabling secure certificate validation in debug mode");
        [request setValidatesSecureCertificate:NO];
    #endif

    return request;
}

@end
