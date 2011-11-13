//
//  AMQPComm.m
//  aware-client-ios
//
//  Created by Adam Watson on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import "AMQPComm.h"


//singleton shared instance
static AMQPComm *sharedInstance;


@implementation AMQPComm



#pragma mark Singleton Methods
+ (id)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        
        [self setupAMQPConnection];
        
    }
    return self;
}


#pragma mark - AMQP 0.9.2 Client

@synthesize amqpConn, amqpGlobalChannel;
@synthesize exchSysFanout, queueSysFanout, opqSysFanout;
@synthesize exchSysComm, queueSysComm, opqSysComm;

- (void)setupAMQPConnection
{
    
    amqpConn = [[AMQPConnection alloc] init];
    [amqpConn connectToHost:kAMQPHostname onPort:kAMQPPortNumber];
    [amqpConn loginAsUser:kAMQPUsername withPassword:kAMQPPassword onVHost:kAMQPVirtualHostname];
    
    amqpGlobalChannel = [[AMQPChannel alloc] init];
    [amqpGlobalChannel openChannel:1 onConnection:amqpConn];
    
    
    DLog(@"AMQP connection established. %@", amqpConn);
}


- (void) setupAMQPSysComm
{
    // create a reference to the server-created system-communication exchange
    exchSysComm = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemComm onChannel:amqpGlobalChannel isPassive:true isDurable:true getsAutoDeleted:false];
    
    //create a sys-comm queue and bind to the sys-comm exchange
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysComm = [[AMQPQueue alloc] initWithName:qnameSysComm onChannel:amqpGlobalChannel isPassive:false isExclusive:true isDurable:false autoDelete:true];
    [queueSysComm bindToExchange:exchSysComm withKey:qnameSysComm];
    
    // create the nsop for consuming system comm messages (replies)
    opqSysComm = [[NSOperationQueue alloc] init];
    [opqSysComm setMaxConcurrentOperationCount:-1];
    [self createConsumerForAMQPQueue:queueSysComm andAddToOpQueue:opqSysComm];
    
    DLog(@"AMQP SysComm queue and consumer instanciated. %@", queueSysComm);
}


- (void) setupAMQPSysFanout
{
    DLog(@"1");
    // create a ref to the server-created system broadcast exchange
    exchSysFanout = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemFanout onChannel:amqpGlobalChannel isPassive:true isDurable:true getsAutoDeleted:false];
    DLog(@"2");
    
    // create client queue and bind to system broadcast exchange
    NSString *qnameSysFanout  = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemFanout, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    DLog(@"3");
    
    queueSysFanout = [[AMQPQueue alloc] initWithName:qnameSysFanout onChannel:amqpGlobalChannel isPassive:false isExclusive:false isDurable:false autoDelete:true];
    [queueSysFanout bindToExchange:exchSysFanout withKey:qnameSysFanout];
    DLog(@"4");
    
    // create the nsop for consuming system broadcast messages
    opqSysFanout = [[NSOperationQueue alloc] init];
    [opqSysFanout setMaxConcurrentOperationCount:-1];
    [self createConsumerForAMQPQueue:queueSysFanout andAddToOpQueue:opqSysFanout];
    
    DLog(@"AMQP SysFanout queue and consumer instanciated. %@", queueSysFanout);

    
    
    
    
    // create a reference to the server-created system-communication exchange
    exchSysComm = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemComm onChannel:amqpGlobalChannel isPassive:true isDurable:true getsAutoDeleted:false];
    
    //create a sys-comm queue and bind to the sys-comm exchange
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysComm = [[AMQPQueue alloc] initWithName:qnameSysComm onChannel:amqpGlobalChannel isPassive:false isExclusive:true isDurable:false autoDelete:true];
    [queueSysComm bindToExchange:exchSysComm withKey:qnameSysComm];
    
    // create the nsop for consuming system comm messages (replies)
    opqSysComm = [[NSOperationQueue alloc] init];
    [opqSysComm setMaxConcurrentOperationCount:-1];
    [self createConsumerForAMQPQueue:queueSysComm andAddToOpQueue:opqSysComm];
    
    DLog(@"AMQP SysComm queue and consumer instanciated. %@", queueSysComm);
    
    
    
    
    
}


- (void)teardownAMQP
{
    
    
    //[queueSysFanout dealloc];
    //[queueSysComm dealloc];
    
    amqpConn = [[AMQPConnection alloc] init];
    
    amqpGlobalChannel = [[AMQPChannel alloc] init];
    
    // create a reference to the server-created system-communication exchange
    exchSysComm = [AMQPExchange alloc] ;
    
    
    
    // create a ref to the server-created system broadcast exchange
    exchSysFanout = [AMQPExchange alloc] ;
    
    
    
    // create the nsop for consuming system comm messages (replies)
    opqSysComm = [[NSOperationQueue alloc] init];
    
    // create the nsop for consuming system broadcast messages
    opqSysFanout = [[NSOperationQueue alloc] init];
    
    
    [self createConsumerForAMQPQueue:queueSysFanout andAddToOpQueue:opqSysFanout];
    
    
    
    DLog(@"AMQP teardown is complete. %@", queueSysFanout);
}



- (void) createConsumerForAMQPQueue: (AMQPQueue *) amqpQueue andAddToOpQueue:
(NSOperationQueue *) opQueue
{
    
    // create the consumer + op
    AMQPConsumer *c = [amqpQueue startConsumerWithAcks:true isExclusive:false receiveLocal:true];
    
    AMQPConsumerOperation *op = [[AMQPConsumerOperation alloc] initWithConsumer:c];
    [op setDelegate:self];
    //[op setQueuePriority:NSOperationQueuePriorityVeryLow];
    [op setQueuePriority:NSOperationQueuePriorityNormal];
    
    // submit the op to the op queue
    [opQueue addOperation:op];
    
}




- (void) amqpMessageHandler:(AMQPMessage*)msg
{
    DLog(@"(%@) %@", msg.exchangeName, msg.body);
    
    // Sys Comm message handler 
    if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemComm])
    {
        
    }
    
    // Broadcast message handler 
    else if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemFanout])
    {
        
    }         
    
    
    
}



/*
 // amqp entities + nsop queues
 
 [opqSysFanout cancelAllOperations];
 [opqSysComm cancelAllOperations];
 
 self.amqpConn = nil;
 self.amqpGlobalChannel = nil;
 
 self.exchSysFanout = nil;
 self.queueSysFanout = nil;
 self.opqSysFanout = nil;
 
 self.exchSysComm = nil;
 self.queueSysComm = nil;
 self.opqSysComm = nil;
 
*/



@end
