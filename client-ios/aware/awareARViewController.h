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
#import "AMQPComm.h"


@interface awareARViewController : UIViewController
{
    NSArray *placesOfInterest;
    CLLocation *lastLocation;
    NSTimer *sendLocationTimer;
}

@property (nonatomic, strong) NSArray *placesOfInterest;


- (void) updateLocationMarkers;
- (void) sendMyLocationToServer;

- (void) startBroadcastingLocation;
- (void) stopBroadcastingLocation;
- (void) broadcastMyLocation;

- (void) startARViewUpdates;
- (void) stopARViewUpdates;
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

