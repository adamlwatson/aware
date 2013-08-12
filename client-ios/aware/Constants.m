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

    //NSString * const kAMQPHostname                  = kDebug ? @"192.168.1.110" : @"node001.ext.alwlabs.com";
    //NSString * const kApiUrlPrefix                  = kDebug ? @"https://adam-15:8000" : @"https://node001.ext.alwlabs.com:8000";
    
    NSString * const kAMQPHostname                  = kDebug ? @"10.15.100.59" : @"node001.ext.alwlabs.com";
    NSString * const kApiUrlPrefix                  = kDebug ? @"https://10.15.100.59:8000" : @"https://node001.ext.alwlabs.com:8000";

    NSString * const kAMQPUsername                  = kDebug ? @"guest" : @"";
    NSString * const kAMQPPassword                  = kDebug ? @"guest" : @"";
    
    NSString * const kAMQPVirtualHostname           = @"/";
    int        const kAMQPPortNumber                = 5672;
    
    NSString * const kAMQPEntityNameSystemComm      = @"aware.system.comm";
    NSString * const kAMQPEntityNameSystemFanout    = @"aware.system.fanout";
    NSString * const kAMQPEntityNameLocation        = @"aware.client.location";

    
    NSString * const kMixpanelAPIToken              = kDebug ? @"59c6249552fd4e59ae08f9e61d14f97b" : @"prodtoken";
