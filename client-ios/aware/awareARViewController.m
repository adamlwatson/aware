//
//  awareARViewController.m
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import "PlaceOfInterest.h"
#import "ARView.h"

#import "awareARViewController.h"

#import "APIUtil.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "AMQPWrapper.h"
#import "MixpanelAPI.h"

#import <CoreLocation/CoreLocation.h>

@implementation awareARViewController

@synthesize placesOfInterest;
@synthesize lastLocation;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateLocations
{
    
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString * buildNo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"];
    NSString * buildDate = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"];
    
    DLog(@"Application Version: %@, Build: %@, Date: %@", version, buildNo, buildDate);

    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel identifyUser:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    //[mixpanel track:@"Launched App" properties:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"test", nil]];
    //[mixpanel flush];
    
    DLog(@"Mixpanel flush called...");
    
    APIUtil *api = [APIUtil sharedInstance];
    __block __weak ASIHTTPRequest *request = [api createAPIRequestWithURI:@"/locations"];
    
    [request setCompletionBlock:^{
        
        NSString *responseString = [request responseString];
        //NSDictionary *headers = [request responseHeaders];
        //int respCode = [request responseStatusCode];
        //NSData *responseData = [request responseData];
        
        NSDictionary *resDict = [responseString objectFromJSONString];
        if ([resDict objectForKey:@"success"] == false) {
            NSArray *res = [resDict objectForKey:@"error"];
            DLog(@"error: %@", res);
            return; //TODO: retry and exponentially back off on failure
        } else {
            //DLog(@"success: %@", resDict);
        }
        
        NSNumber *numPois = [resDict valueForKey:@"result_count"];
        NSArray *resultArr = [resDict objectForKey:@"result"];
        
        NSMutableArray *allPois = [NSMutableArray arrayWithCapacity:[numPois intValue]];
        
        for (id result in resultArr) {
            
            // get the text for this poi
            NSString *locText = [result valueForKey:@"label"];
            
            // get the CLLocation coordinate for this poi
            NSArray *curLoc = [result valueForKey:@"location"]; //2 element array, lat / long
            NSNumber *latitude = [curLoc objectAtIndex:0];
            NSNumber *longitude = [curLoc objectAtIndex:1];
            
            CLLocation *coord = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]]; 
        
            // create the label views for all points of interest
            for (int i = 0; i < [numPois intValue]; i++) {
                UILabel *label = [[UILabel alloc] init];
                label.adjustsFontSizeToFitWidth = NO;
                label.opaque = NO;
                label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
                label.center = CGPointMake(200.0f, 200.0f);
                label.textAlignment = UITextAlignmentCenter;
                label.textColor = [UIColor whiteColor];
                label.text = locText;		
                CGSize size = [label.text sizeWithFont:label.font];
                label.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
                
                PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:label at:coord];
                [allPois insertObject:poi atIndex:i];
            }		
        }
        
        //NSArray *result = [allPois copy];
        //return result;
        
        DLog(@"** Device UDID: %@", [[UIDevice currentDevice] uniqueDeviceIdentifier] );
        DLog(@"** Global Device UDID: %@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] );
        
        DLog(@"Setting places of interest...");
        
        ARView *arView = (ARView *)self.view;
        [arView setPlacesOfInterest:allPois];
        
        DLog(@"Setting up AMQP consumer...");
        [self setupAMQP];

        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        DLog(@"an error occurred while calling the REST api... %@", error);
    }];
    
    [request startAsynchronous];

}


- (void) sendMyLocationToServer
{
    ARView *arView = (ARView *)self.view;
    CLLocation *loc = [arView userLocation];
    //DLog(@"loc nil? %s", (loc == nil) ? "true" : "false");
    //DLog(@"lat diff = %s", (loc.coordinate.latitude != self.lastLocation.coordinate.latitude) ? "true" : "false");
    //DLog(@"long diff = %s", (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) ? "true" : "false");
    
    if ((loc != nil) &&
        (
         (loc.coordinate.latitude != self.lastLocation.coordinate.latitude ) ||
         (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) )
        ) {
        
        DLog(@"uploading location change: %@", loc);
        self.lastLocation = [loc copy];
    
        APIUtil *api = [APIUtil sharedInstance];
        NSString *uri = [NSString stringWithFormat:@"/sendlocation/%f/%f", loc.coordinate.latitude, loc.coordinate.longitude ];
        
        __block __weak ASIHTTPRequest *request = [api createAPIRequestWithURI:uri];

        [request setCompletionBlock:^{
            
            NSString *responseString = [request responseString];
            //NSDictionary *headers = [request responseHeaders];
            //int respCode = [request responseStatusCode];
            //NSData *responseData = [request responseData];
            
            NSDictionary *resDict = [responseString objectFromJSONString];
            if ([resDict objectForKey:@"success"] == false) {
                NSArray *err = [resDict objectForKey:@"error"];
                DLog(@"error: %@", err);
                return; //TODO: retry and exponentially back off on failure
            } else {
                //DLog(@"success: %@", resDict);
            }
            
            //NSNumber *numResults = [resDict valueForKey:@"result_count"];
            //NSArray *resultArr = [resDict objectForKey:@"result"];
            
        
        }];
    
        [request setFailedBlock:^{
            NSError *error = [request error];
            DLog(@"an error occurred while calling the REST api... %@", error);
        }];

        [request startAsynchronous];
    }
}

     
#pragma mark - AMQP 0.9.2 Client

@synthesize amqpConn, amqpGlobalChannel;
@synthesize exchSysFanout, queueSysFanout, opqSysFanout;
@synthesize exchSysComm, queueSysComm, opqSysComm;

- (void)setupAMQP
{
    
    amqpConn = [[AMQPConnection alloc] init];
    [amqpConn connectToHost:kAMQPHostname onPort:kAMQPPortNumber];
    [amqpConn loginAsUser:kAMQPUsername withPassword:kAMQPPassword onVHost:kAMQPVirtualHostname];
    
    amqpGlobalChannel = [[AMQPChannel alloc] init];
    [amqpGlobalChannel openChannel:1 onConnection:amqpConn];
    
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
    
    
    // create a ref to the server-created system broadcast exchange
    exchSysFanout = [[AMQPExchange alloc] initFanoutExchangeWithName:kAMQPEntityNameSystemFanout onChannel:amqpGlobalChannel isPassive:true isDurable:true getsAutoDeleted:false];
    
    // create client queue and bind to system broadcast exchange
    NSString *qnameSysFanout  = [NSString stringWithFormat:@"%@.%@", kAMQPEntityNameSystemFanout, [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    queueSysFanout = [[AMQPQueue alloc] initWithName:qnameSysFanout onChannel:amqpGlobalChannel isPassive:false isExclusive:false isDurable:false autoDelete:true];
    [queueSysFanout bindToExchange:exchSysFanout withKey:qnameSysFanout];

    // create the nsop for consuming system broadcast messages
    opqSysFanout = [[NSOperationQueue alloc] init];
    [opqSysFanout setMaxConcurrentOperationCount:-1];
    [self createConsumerForAMQPQueue:queueSysFanout andAddToOpQueue:opqSysFanout];
     
    
    
    DLog(@"AMQP init is complete. %@", queueSysFanout);
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
    
    if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemComm])
    {
        DLog(@"SysComm!");        
    }
        
    else if ([msg.exchangeName isEqualToString:kAMQPEntityNameSystemFanout])
    {
        DLog(@"Broadcast!");
    }         
    
    DLog(@"(%@) %@", msg.exchangeName, msg.body);
    
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self updateLocations];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [opqSysFanout cancelAllOperations];
    [opqSysComm cancelAllOperations];
    
    
    DLog(@"in awareARViewController::viewDidUnload");
    self.placesOfInterest = nil;
    self.lastLocation = nil;
    
    
    // amqp entities + nsop queues
    
    self.amqpConn = nil;
    self.amqpGlobalChannel = nil;
    
    self.exchSysFanout = nil;
    self.queueSysFanout = nil;
    self.opqSysFanout = nil;
    
    self.exchSysComm = nil;
    self.queueSysComm = nil;
    self.opqSysComm = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ARView *arView = (ARView *)self.view;
	[arView start];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	ARView *arView = (ARView *)self.view;
	[arView stop];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
