//
//  awareARViewController.h
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CRVStompClient.h"

@class CRVStompClient;
@protocol CRVStompClientDelegate;

@interface awareARViewController : UIViewController<CRVStompClientDelegate> {
    @private
    CRVStompClient *service;
}

@property (nonatomic, strong) NSArray *placesOfInterest;

@property (assign) NSTimer *sendLocationTimer;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CRVStompClient *stompClient;


- (void) updateLocations;
- (void) sendMyLocationToServer;
- (void) setupStompQueues;

- (void)stompClientDidConnect:(CRVStompClient *)stompService;
- (void)stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader;

@end

