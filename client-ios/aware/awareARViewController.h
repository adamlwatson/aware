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
    AMQPChannel *amqpGlobalChannel;
    
    AMQPExchange *exchSysFanout;
    AMQPQueue *queueSysFanout;
    NSOperationQueue *opqSysFanout;
    
    AMQPExchange *exchSysComm;
    AMQPQueue *queueSysComm;
    NSOperationQueue *opqSysComm;
    
}

@property (nonatomic, strong) NSArray *placesOfInterest;
@property (nonatomic, strong) CLLocation *lastLocation;


// amqp entities + nsop queues

@property (nonatomic, strong) AMQPConnection *amqpConn;
@property (nonatomic, strong) AMQPChannel *amqpGlobalChannel;

@property (nonatomic, strong) AMQPExchange *exchSysFanout;
@property (nonatomic, strong) AMQPQueue *queueSysFanout;
@property (nonatomic, strong) NSOperationQueue *opqSysFanout;


@property (nonatomic, strong) AMQPExchange *exchSysComm;
@property (nonatomic, strong) AMQPQueue *queueSysComm;
@property (nonatomic, strong) NSOperationQueue *opqSysComm;




// rest api
- (void) updateLocations;
- (void) sendMyLocationToServer;

// amqp c client
- (void) setupAMQP;
- (void) createConsumerForAMQPQueue: (AMQPQueue *) amqpQueue andAddToOpQueue:
(NSOperationQueue *) opQueue;

- (void) queueSysFanoutReceiveHandler:(AMQPMessage*)msg;

- (void) queueSysCommReceiveHandler:(AMQPMessage*)msg;


@end

