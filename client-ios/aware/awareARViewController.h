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
#import "AMQPWrapper.h"

@class CRVStompClient;
@protocol CRVStompClientDelegate;
//CRVStompClientDelegate,
@interface awareARViewController : UIViewController<AMQPConsumerThreadDelegate> {
    @private
    CRVStompClient *service;
}

@property (nonatomic, strong) NSArray *placesOfInterest;
@property (assign) NSTimer *sendLocationTimer;
@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) CRVStompClient *stompClient;

@property (nonatomic, strong) AMQPConnection *conn;
@property (nonatomic, strong) AMQPChannel *channel;
@property (nonatomic, strong) AMQPQueue *queue;
@property (nonatomic, strong) AMQPConsumer *consumer;
@property (nonatomic, strong) AMQPConsumerThread *thread;

//rest
- (void) updateLocations;
- (void) sendMyLocationToServer;

//stomp client
- (void) setupStompQueues;
- (void) stompClientDidConnect:(CRVStompClient *)stompService;
- (void) stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader;

//amqp c client
- (void) setupAMQPConsumer;
- (void) amqpConsumerThreadReceivedNewMessage:(AMQPMessage*)msg;



@end

