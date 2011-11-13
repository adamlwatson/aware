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


@interface awareARViewController : UIViewController
{
    NSArray *placesOfInterest;
    CLLocation *lastLocation;
    
    
}

@property (nonatomic, strong) NSArray *placesOfInterest;
@property (nonatomic, strong) CLLocation *lastLocation;



// rest api
- (void) updateLocations;
- (void) sendMyLocationToServer;


@end

