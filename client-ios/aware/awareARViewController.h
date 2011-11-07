//
//  awareARViewController.h
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "AMQPWrapper.h"

@interface awareARViewController : UIViewController<AMQPConsumerOperationDelegate>
{
    NSArray *placesOfInterest;
    CLLocation *lastLocation;
    
    AMQPConnection *amqpConn;
    AMQPChannel *channel;
    AMQPQueue *queue;
    AMQPExchange *exchange;
    AMQPConsumer *consumer;
    AMQPConsumerOperation *consumerOp;
    NSOperationQueue *consumerOpq;
}

@property (nonatomic, strong) NSArray *placesOfInterest;

@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) AMQPConnection *amqpConn;
@property (nonatomic, strong) AMQPChannel *channel;
@property (nonatomic, strong) AMQPQueue *queue;
@property (nonatomic, strong) AMQPExchange *exchange;
@property (nonatomic, strong) AMQPConsumer *consumer;
@property (nonatomic, strong) AMQPConsumerOperation *consumerOp;
@property (nonatomic, strong) NSOperationQueue *consumerOpq;

// op queues


// rest api
- (void) updateLocations;
- (void) sendMyLocationToServer;

// amqp c client
- (void) setupAMQPConsumer;
- (void) amqpConsumerReceivedMessage:(AMQPMessage*)msg;



@end

