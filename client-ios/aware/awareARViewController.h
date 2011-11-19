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
    AMQPComm *amqp;
    NSTimer *sendLocationTimer;
}

@property (nonatomic, strong) NSArray *placesOfInterest;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (strong, nonatomic) AMQPComm *amqp;
@property (strong, nonatomic) NSTimer *sendLocationTimer;



// rest api
- (void) updateLocations;
- (void) sendMyLocationToServer;

- (void) sendMessageToServer:(NSDictionary *)dict;
- (void) sendMessageToServer:(NSDictionary *)dict withRoutingKey:(BOOL)withKey;
- (void) sendLocationMessageToServer:(CLLocation *)loc;

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

