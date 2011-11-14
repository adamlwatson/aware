//
//  AMQPComm.h
//  aware-client-ios
//
//  Created by Adam Watson on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AMQPWrapper.h"

@interface AMQPComm : NSObject <AMQPConsumerOperationDelegate> {
    NSOperationQueue *sharedQueue;
    
    AMQPConnection *amqpConn1;
    AMQPChannel *amqpChannel1;
    AMQPConnection *amqpConn2;
    AMQPChannel *amqpChannel2;
    
    AMQPExchange *exchSysFanout;
    AMQPQueue *queueSysFanout;
    NSOperationQueue *opqSysFanout;
    
    AMQPExchange *exchSysComm;
    AMQPQueue *queueSysComm;
    NSOperationQueue *opqSysComm;
}
// amqp entities + nsop queues

@property (nonatomic, strong) NSOperationQueue *sharedQueue;

@property (nonatomic, strong) AMQPConnection *amqpConn1;
@property (nonatomic, strong) AMQPChannel *amqpChannel1;

@property (nonatomic, strong) AMQPConnection *amqpConn2;
@property (nonatomic, strong) AMQPChannel *amqpChannel2;


@property (nonatomic, strong) AMQPExchange *exchSysFanout;
@property (nonatomic, strong) AMQPQueue *queueSysFanout;
@property (nonatomic, strong) NSOperationQueue *opqSysFanout;


@property (nonatomic, strong) AMQPExchange *exchSysComm;
@property (nonatomic, strong) AMQPQueue *queueSysComm;
@property (nonatomic, strong) NSOperationQueue *opqSysComm;

+ (id) sharedInstance;


// amqp c client
- (void) connect;
- (void) setupAMQPSysComm;
- (void) setupAMQPSysFanout;

- (void) teardownAMQP;
- (void) createConsumerForAMQPQueue: (AMQPQueue *) amqpQueue andAddToOpQueue:(NSOperationQueue *) opQueue;

- (void) amqpMessageHandler:(AMQPMessage*)msg;




@end
