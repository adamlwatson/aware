//
//  AMQPComm.h
//  aware-client-ios
//
//  Created by Adam Watson on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#import "AMQPWrapper.h"

@interface AMQPComm : NSObject <AMQPConsumerOperationDelegate> {
    
    BOOL connected;
    
    NSOperationQueue *sharedOpQueue;
    
    AMQPConnection *amqpConn;
    AMQPChannel *amqpChannel;

    AMQPExchange *exchSysComm;
    AMQPQueue *queueSysComm;
    AMQPConsumer *consumerSysComm;

    AMQPExchange *exchLocation;
    NSTimer *broadcastLocationTimer;
}

// amqp entities + nsop queues
@property (nonatomic, strong) AMQPExchange *exchLocation;

+ (id) sharedInstance;

// amqp c client
- (void) connect;
- (void) disconnect;
- (BOOL) isConnected;

// broadcast given location to the clients' personal location fanout exchange
- (void) broadcastLocationMessage:(CLLocation *)loc;

- (void) sendConnectMessage;
- (void) sendDisconnectMessage;
- (void) sendLocationMessage:(CLLocation *)loc;

- (void) sendMessage:(NSDictionary *)dict;
- (void) sendMessage:(NSDictionary *)dict toExchange:(AMQPExchange *)exch withRoutingKey:(NSString *)key;
//- (void) sendMessage:(NSDictionary *)dict withRoutingKey:(NSString *)key;

@end
