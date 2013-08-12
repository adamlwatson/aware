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
        
        amqpConn = [[AMQPConnection alloc] init];
        amqpChannel = [[AMQPChannel alloc] init];
        
        sharedOpQueue = [[NSOperationQueue alloc] init];
        [sharedOpQueue setMaxConcurrentOperationCount:1];
        
    }
    return self;
}


#pragma mark - AMQP 0.9.2 Client

@synthesize exchLocation;

- (void)connect
{
    DLog(@"AMQP connecting and opening channel"); 
    
    [amqpConn connectToHost:kAMQPHostname onPort:kAMQPPortNumber];
    [amqpConn loginAsUser:kAMQPUsername withPassword:kAMQPPassword onVHost:kAMQPVirtualHostname];
    
    [amqpChannel openChannel:1 onConnection:amqpConn];
    
    DLog(@"AMQP channel: %@", amqpChannel);
    
    DLog(@"AMQP setting up syscomm exchange reference"); 
    // create a reference to the server-created system-communication exchange
    exchSysComm = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemComm onChannel:amqpChannel isPassive:true isDurable:true getsAutoDeleted:false];
    
    DLog(@"AMQP setting up client location exchange and starting location broadcast"); 
    // create a an exchange that other clients and server can bind to for my location updates
    NSString *exchLocationName = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameLocation, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    exchLocation = [[AMQPExchange alloc] initFanoutExchangeWithName:exchLocationName onChannel:amqpChannel isPassive:false isDurable:false getsAutoDeleted:false];
    
    DLog(@"AMQP setting up syscomm queue"); 
    
    //create a sys-comm queue and bind to the sys-comm exchange
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysComm = [[AMQPQueue alloc] initWithName:qnameSysComm onChannel:amqpChannel isPassive:false isExclusive:false isDurable:false autoDelete:false];
    DLog(@"AMQP binding syscomm queue"); 
    
    //bind to sys comm queue with unique and broadcast routing keys 
    [queueSysComm bindToExchange:exchSysComm withKey:qnameSysComm];
    [queueSysComm bindToExchange:exchSysComm withKey:@"aware.system.comm.broadcast"];

    DLog(@"AMQP creating syscomm queue consumer"); 
    
    // create the consumer + op
    consumerSysComm = [queueSysComm startConsumerWithAcks:true isExclusive:false receiveLocal:true];
    
    DLog(@"AMQP creating consumer op and adding to nsopqueue"); 
    
    AMQPConsumerOperation *op = [[AMQPConsumerOperation alloc] initWithConsumer:consumerSysComm];
    [op setDelegate:sharedInstance];
    [op setQueuePriority:NSOperationQueuePriorityNormal];
    
    // submit the op to the op queue
    [sharedOpQueue setSuspended:false];
    [sharedOpQueue addOperation:op];
    
    DLog(@"AMQP connection established");

    connected = true;
}


- (void)disconnect
{
    
    DLog(@"AMQP cancelling nsopqueue");
    
    [sharedOpQueue cancelAllOperations];
    [sharedOpQueue waitUntilAllOperationsAreFinished];
    [sharedOpQueue setSuspended:true];
    
    DLog(@"AMQP cancelling syscomm consumer");
    
    [consumerSysComm cancel];

    DLog(@"AMQP purging syscomm queue");
    
    [queueSysComm purge];
    
    DLog(@"AMQP unbinding syscomm broadcast queue");
    
    [queueSysComm unbindFromExchange:exchSysComm withKey:@"aware.system.comm.broadcast"];
    
    DLog(@"AMQP unbinding syscomm client queue");
    
    NSString *qnameSysComm = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemComm, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    [queueSysComm unbindFromExchange:exchSysComm withKey:qnameSysComm];
        
    DLog(@"AMQP deleting syscomm queue");
    
    [queueSysComm deleteQueue];
    queueSysComm = nil;
    
    DLog(@"AMQP deleting location exchange");
    [exchLocation deleteExchange:false];
    exchLocation = nil;
    
    DLog(@"AMQP closing channel and disconnecting");

    [amqpChannel close];
    
    [amqpConn disconnect];
    
    
    connected = false;
    
    DLog(@"AMQP disconnect is complete");
    
}


-(void) sendConnectMessage
{
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:@"connect" forKey:@"msg_type"];
    [self sendMessage: msg];
}

-(void) sendDisconnectMessage
{
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:@"disconnect" forKey:@"msg_type"];
    [self sendMessage: msg];
    
}

//generates a properly formed message for sending location updates via amqp
-(NSDictionary *) generateLocationMessage:(CLLocation *)loc
{
    NSString *lat = [NSString stringWithFormat:@"%f", loc.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", loc.coordinate.longitude];
    
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    
    [msg setValue:@"location_update" forKey:@"msg_type"];
    [msg setValue:lat forKey:@"latitude"];
    [msg setValue:lon forKey:@"longitude"];

    return msg;
}

// send current location to the amqp broker
-(void) sendLocationMessage:(CLLocation *)loc
{
    [self sendMessage: [self generateLocationMessage:loc]];
}

// executed every n seconds to send current location message out to this clients' location excahange
-(void) broadcastLocationMessage:(CLLocation *)loc
{
    //[exchLocation publishMessage:[msg JSONString] usingRoutingKey:@""];

    [self sendMessage:[self generateLocationMessage:loc] toExchange:exchLocation withRoutingKey:@""];
}

//convience method since we send to exchSysComm with no routing key most of the time
-(void) sendMessage:(NSDictionary *)dict
{
    [self sendMessage:dict toExchange:exchSysComm withRoutingKey:@""];
}

- (void) sendMessage:(NSDictionary *)dict toExchange:(AMQPExchange *)exch withRoutingKey:(NSString *)key
{    
    //NSString *routingKey = key ? [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] : @"";
    
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"udid"];
    [msg addEntriesFromDictionary: dict];
    
    [exch publishMessage:[msg JSONString] usingRoutingKey:key];
    
}




- (void) amqpMessageHandler:(AMQPMessage*)msg
{
    //DLog(@"(%@) %@", msg.exchangeName, msg.body);
    
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
