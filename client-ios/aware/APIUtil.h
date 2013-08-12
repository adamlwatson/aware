//
//  APIUtil.h
//  aware-client-ios
//
//  Created by Adam Watson on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


@interface APIUtil : NSObject 


// methods
+ (id)sharedInstance;

- (id)createAPIRequestWithURI:(NSString *)uri;


@end
