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

#import <CoreLocation/CoreLocation.h>

@implementation awareARViewController

@synthesize placesOfInterest;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateLocations
{
    APIUtil *api = [APIUtil sharedInstance];
    __block __weak ASIHTTPRequest *request = [api createAPIRequestObject];
    
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
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"an error occurred while calling the REST api... %@", error);
    }];
    
    [request startAsynchronous];
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
