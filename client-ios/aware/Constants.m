//
//  Constants.m
//  aware-client-ios
//
//  Created by Adam Watson on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
    BOOL const kDebug = true;
#else
    BOOL const kDebug = false;
#endif

    NSString * const kAMQPHostname =                kDebug ? @"192.168.1.110" : @"prod-server";
    NSString * const kAMQPUsername =                kDebug ? @"guest" : @"";
    NSString * const kAMQPPassword =                kDebug ? @"guest" : @"";
    
    NSString * const kAMQPVirtualHostname =         @"/";
    int        const kAMQPPortNumber =              5672;
    
    NSString * const kAMQPEntityNameSystemIn =      @"aware.system.in";
    NSString * const kAMQPEntityNameSystemFanout =  @"aware.system.fanout";


