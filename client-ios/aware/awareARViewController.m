//
//  awareARViewController.m
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "awareARViewController.h"
#import "PlaceOfInterest.h"
#import "ARView.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "apiutil.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "CRVStompClient.h"

#import <CoreLocation/CoreLocation.h>

@implementation awareARViewController

@synthesize placesOfInterest;
@synthesize sendLocationTimer;
@synthesize lastLocation;
@synthesize stompClient;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateLocations
{
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
            NSLog(@"error: %@", res);
            return; //TODO: retry and exponentially back off on failure
        } else {
            NSLog(@"success: %@", resDict);
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
        
        NSLog(@"** Device UDID: %@", [[UIDevice currentDevice] uniqueDeviceIdentifier] );
        NSLog(@"** Global Device UDID: %@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] );
        
        NSLog(@"Setting places of interest...");
        
        ARView *arView = (ARView *)self.view;
        [arView setPlacesOfInterest:allPois];
        
        // send my location every second to the server
        //NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendMyLocationToServer) userInfo:nil repeats:true];
        //self.sendLocationTimer = t;
        
        [self setupStompQueues];
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"an error occurred while calling the REST api... %@", error);
    }];
    
    [request startAsynchronous];

}


- (void) sendMyLocationToServer
{
    ARView *arView = (ARView *)self.view;
    CLLocation *loc = [arView userLocation];
    //NSLog(@"loc nil? %s", (loc == nil) ? "true" : "false");
    //NSLog(@"lat diff = %s", (loc.coordinate.latitude != self.lastLocation.coordinate.latitude) ? "true" : "false");
    //NSLog(@"long diff = %s", (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) ? "true" : "false");
    
    if ((loc != nil) &&
        (
         (loc.coordinate.latitude != self.lastLocation.coordinate.latitude ) ||
         (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) )
        ) {
        
        NSLog(@"uploading location change: %@", loc);
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
                NSLog(@"error: %@", err);
                return; //TODO: retry and exponentially back off on failure
            } else {
                //NSLog(@"success: %@", resDict);
            }
            
            //NSNumber *numResults = [resDict valueForKey:@"result_count"];
            //NSArray *resultArr = [resDict objectForKey:@"result"];
            
        
        }];
    
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"an error occurred while calling the REST api... %@", error);
        }];

        [request startAsynchronous];
    }
}

     
#pragma mark - Stomp Queues

#define kUsername   @"guest"
#define kPassword   @"guest"
//#define kQueueName  @"/amq/queue/stream.one"
#define kQueueName  @"/exchange/aware.fanout"

     
- (void) setupStompQueues
{
    NSLog(@"Setting up stomp client...");
    CRVStompClient *s = [[CRVStompClient alloc] 
                         initWithHost:@"192.168.1.110" 
                         port:61613 
                         login:kUsername
                         passcode:kPassword
                         delegate:self];
    [s connect];
    
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:     
                             @"client", @"ack", 
                             @"true", @"activemq.dispatchAsync",
                             @"1", @"activemq.prefetchSize", nil];
    [s subscribeToDestination:kQueueName withHeader: headers];
    
    NSLog(@"connected to stomp service: %@", kQueueName);
    
    [self setStompClient: s];
    
}

#pragma mark CRVStompClientDelegate
- (void)stompClientDidConnect:(CRVStompClient *)stompService {
    NSLog(@"stompServiceDidConnect");
}

- (void)stompClient:(CRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader {
    NSLog(@"gotMessage body: %@, header: %@", body, messageHeader);
    NSLog(@"Message ID: %@", [messageHeader valueForKey:@"message-id"]);
    // If we have successfully received the message ackknowledge it.
    [stompService ack: [messageHeader valueForKey:@"message-id"]];
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
    
    [stompClient unsubscribeFromDestination: kQueueName];
    
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
    
    if (self.sendLocationTimer != nil) {
        [sendLocationTimer invalidate];
        self.sendLocationTimer = nil;

    }
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
