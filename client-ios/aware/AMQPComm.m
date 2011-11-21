//
//  AMQPComm.m
//  aware-client-ios
//
//  Created by Adam Watson on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import "AMQPComm.h"
#import "AMQPWrapper.h"
#import "Constants.h"
#import "JSONKit.h"


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
        
        connected = false;
        
        amqpConn1 = [[AMQPConnection alloc] init];
        amqpChannel1 = [[AMQPChannel alloc] init];
        
        amqpConn2 = [[AMQPConnection alloc] init];
        amqpChannel2 = [[AMQPChannel alloc] init];
    
        opqSysComm = [[NSOperationQueue alloc] init];
        opqSysFanout = [[NSOperationQueue alloc] init];
        
        
        
    }
    return self;
}


#pragma mark - AMQP 0.9.2 Client

@synthesize connected;
@synthesize sharedQueue;
@synthesize amqpConn1, amqpChannel1;
@synthesize amqpConn2, amqpChannel2;
@synthesize exchSysFanout, queueSysFanout, opqSysFanout;
@synthesize exchSysComm, queueSysComm, opqSysComm;

- (void)connect
{
    [self setupAMQPSysComm];
    [self setupAMQPSysFanout];
    
    self.connected = true;
}


- (void) setupAMQPSysComm
{

    [amqpConn1 connectToHost:kAMQPHostname onPort:kAMQPPortNumber];
    [amqpConn1 loginAsUser:kAMQPUsername withPassword:kAMQPPassword onVHost:kAMQPVirtualHostname];
    
    [amqpChannel1 openChannel:1 onConnection:amqpConn1];
        
    DLog(@"AMQP connection 1 established. %@", amqpConn1);
    
    // create a reference to the server-created system-communication exchange
    if (exchSysComm == nil) {
        exchSysComm = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemComm onChannel:amqpChannel1 isPassive:true isDurable:true getsAutoDeleted:false];
    }
    //create a sys-comm queue and bind to the sys-comm exchange
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysComm = [[AMQPQueue alloc] initWithName:qnameSysComm onChannel:amqpChannel1 isPassive:false isExclusive:true isDurable:false autoDelete:true];
    [queueSysComm bindToExchange:exchSysComm withKey:qnameSysComm];
    
    // create the nsop for consuming system comm messages (replies)
    [opqSysComm setMaxConcurrentOperationCount:1];
    //[sharedInstance createConsumerForAMQPQueue:queueSysComm andAddToOpQueue:opqSysComm];
    
    DLog(@"AMQP SysComm queue active. %@", queueSysComm);
}


- (void) setupAMQPSysFanout
{
    [amqpConn2 connectToHost:kAMQPHostname onPort:kAMQPPortNumber];
    [amqpConn2 loginAsUser:kAMQPUsername withPassword:kAMQPPassword onVHost:kAMQPVirtualHostname];
    
    [amqpChannel2 openChannel:1 onConnection:amqpConn2];
    
    DLog(@"AMQP connection 2 established. %@", amqpConn2);


    // create a ref to the server-created system broadcast exchange
    if (exchSysFanout == nil) {
        exchSysFanout = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemFanout onChannel:amqpChannel2 isPassive:true isDurable:true getsAutoDeleted:false];
    }
    
    // create client queue and bind to system broadcast exchange
    NSString *qnameSysFanout  = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemFanout, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysFanout = [[AMQPQueue alloc] initWithName:qnameSysFanout onChannel:amqpChannel2 isPassive:false isExclusive:false isDurable:false autoDelete:true];
    [queueSysFanout bindToExchange:exchSysFanout withKey:qnameSysFanout];
    
    // create the nsop for consuming system broadcast messages
    [opqSysFanout setMaxConcurrentOperationCount:1];
    //[sharedInstance createConsumerForAMQPQueue:queueSysFanout andAddToOpQueue:opqSysFanout];
    
    DLog(@"AMQP SysFanout queue active. %@", queueSysFanout);    
    
}



- (void)teardownAMQP
{

    //TODO: Also unbind queue from exchange BY ROUTING KEY
    NSString *qnameSysFanout  = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemFanout, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    [queueSysFanout unbindFromExchange:exchSysFanout withKey:qnameSysFanout];
   
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    [queueSysComm unbindFromExchange:exchSysComm withKey:qnameSysComm];
    
    [queueSysComm deleteQueue];
    [queueSysFanout deleteQueue];
    
    queueSysComm = nil;
    queueSysFanout = nil;
    
    //[exchSysComm deleteExchange:false];
    //[exchSysFanout deleteExchange:false];
    
    [amqpChannel1 close];
    [amqpChannel2 close];
    
    //amqpChannel1 = nil;
    //amqpChannel2 = nil;
    
    
    [amqpConn1 disconnect];
    [amqpConn2 disconnect];
    //amqpConn1 = nil;
    //amqpConn2 = nil;
    
    [opqSysComm cancelAllOperations];
    [opqSysComm setSuspended:true];
    opqSysComm = nil;
    
    [opqSysFanout cancelAllOperations];
    [opqSysFanout setSuspended:true];
    opqSysFanout = nil;
    
    self.connected = false;
    
    DLog(@"AMQP teardown is complete.");
    
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



-(void) sendConnectMessageToServer
{
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:@"connect" forKey:@"msg_type"];
    [self sendMessageToServer: msg];
}

-(void) sendDisconnectMessageToServer
{
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:@"disconnect" forKey:@"msg_type"];
    [self sendMessageToServer: msg];
    
}

-(void) sendLocationMessageToServer:(CLLocation *)loc
{
    
    NSString *lat = [NSString stringWithFormat:@"%f", loc.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", loc.coordinate.longitude];
    
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    
    [msg setValue:@"location_update" forKey:@"message_type"];
    [msg setValue:lat forKey:@"latitude"];
    [msg setValue:lon forKey:@"longitude"];
    
    [self sendMessageToServer: msg];
}


//convience method since we don't want to send with a routing key most of the time
-(void) sendMessageToServer:(NSDictionary *)dict
{
    [self sendMessageToServer:dict withRoutingKey:false];
}

- (void) sendMessageToServer:(NSDictionary *)dict withRoutingKey:(BOOL)withKey
{
    
    //set udid as routing key if requested.
    NSString *routingKey = withKey ? [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] : @"";
    
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"udid"];
    [msg addEntriesFromDictionary: dict];
    
    [exchSysComm publishMessage:[msg JSONString] usingRoutingKey:routingKey];
    
    DLog(@"[amqp] sent: %@ ",[msg JSONString]);
    
    
}



- (void) amqpMessageHandler:(AMQPMessage*)msg
{
    DLog(@"(%@) %@", msg.exchangeName, msg.body);
    
    // Sys Comm message handler 
    if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemComm])
    {
        NSDictionary *msgDict = [msg.body objectFromJSONString];
        
        if ( [[msgDict valueForKey:@"msg_type"] isEqualToString:@"heartbeat"] )
        {
            NSString *udid = [msgDict valueForKey:@"udid"];
            NSString *ts = [msgDict valueForKey:@"timestamp"];
            DLog(@"[amqp] Server Heartbeat: %@ %@", udid, ts);

        }
            
        
        
    }
    
    // Broadcast message handler 
    else if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemFanout])
    {
        
    }         
    
    
    
}

-(BOOL) isConnected
{
    return connected;
}


@end
