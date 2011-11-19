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
#import "Util.h"

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
@synthesize sendLocationTimer;
@synthesize amqp;


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
    
    if ((loc != nil) && (loc != lastLocation) &&
        (
         (loc.coordinate.latitude != self.lastLocation.coordinate.latitude ) ||
         (loc.coordinate.longitude != self.lastLocation.coordinate.longitude)))
        {
            self.lastLocation = [loc copy];
            [self sendLocationMessageToServer: loc];
        }
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
    //APIUtil *api = [APIUtil sharedInstance];
    amqp = [AMQPComm sharedInstance];
    AMQPExchange *exch = [amqp exchSysComm];
    
    //set udid as routing key if requested.
    NSString *routingKey = withKey ? [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] : @"";
    
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] forKey:@"udid"];
    [msg addEntriesFromDictionary: dict];
    
    [exch publishMessage:[msg JSONString] usingRoutingKey:routingKey];
    
    DLog(@"[amqp] sent: %@ ",[msg JSONString]);
    
    
}
    

/*
- (void) sendMyLocationToServer
{
    ARView *arView = (ARView *)self.view;
    CLLocation *loc = [arView userLocation];
    DLog(@"loc nil? %s", (loc == nil) ? "true" : "false");
    DLog(@"lat diff = %s", (loc.coordinate.latitude != self.lastLocation.coordinate.latitude) ? "true" : "false");
    DLog(@"long diff = %s", (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) ? "true" : "false");
    
    if ((loc != nil) &&
        (
         (loc.coordinate.latitude != self.lastLocation.coordinate.latitude ) ||
         (loc.coordinate.longitude != self.lastLocation.coordinate.longitude) )
        ) {
        
        DLog(@"sending location change: %@", loc);
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

*/




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DLog(@"awareARViewController::viewDidLoad()");
    [super viewDidLoad];

    
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString * buildNo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"];
    NSString * buildDate = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"];
    
    DLog(@"Application Version: %@, Build: %@, Date: %@", version, buildNo, buildDate);
    
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel identifyUser:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
    //[mixpanel track:@"Launched App" properties:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"test", nil]];
    //[mixpanel flush];

    
    [self updateLocations];
    
    
    amqp = [AMQPComm sharedInstance];
    //[amqp connect];
    [amqp setupAMQPSysComm]; 
    [amqp setupAMQPSysFanout];
    
    [self sendConnectMessageToServer];
    
    // send my location to the server periodically
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendMyLocationToServer) userInfo:nil repeats:true];
    self.sendLocationTimer = t;
    
    /*
     DLog(@"Registering as observer: %@", self.view);
     ARView *arView = (ARView *)self.view;
     [self addObserver:arView forKeyPath:@"location" options:0 context:NULL];
     */

    ARView *arView = (ARView *)self.view;
	[arView start];

}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"#### In observeValueForKeyPath!");
    
    if ([keyPath isEqual:@"location"]) {
        
        DLog(@"#### Got keypath change from location manager!");
        CLLocation *loc = [object valueForKey:@"location"];
        DLog(@"Location: %@", loc); 
        
    }
}
*/


- (void)viewDidUnload
{
    
    DLog(@"in awareARViewController::viewDidUnload");
    [super viewDidUnload];
    
    
    [self sendDisconnectMessageToServer];
    amqp = [AMQPComm sharedInstance];
    [amqp teardownAMQP];
    
    [self.sendLocationTimer invalidate];
 
    
    
    self.placesOfInterest = nil;
    self.lastLocation = nil;
    
        
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"awareARViewController::viewWillAppear()");
    [super viewWillAppear:animated];

    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"awareARViewController::viewDidAppear()");
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"awareARViewController::viewWillDisappear()");
	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"awareARViewController::viewDidDisappear()");
	[super viewDidDisappear:animated];
	
    //TODO: properly setup/teardown ar view and server connection when view focus changes
    //ARView *arView = (ARView *)self.view;
	//[arView stop];

           
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
