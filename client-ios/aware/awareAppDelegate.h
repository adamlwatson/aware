//
//  awareAppDelegate.h
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "MixpanelAPI.h"
#import "AMQPComm.h"


@class awareARViewController;

@interface awareAppDelegate : NSObject <UIApplicationDelegate> {
    MixpanelAPI *mixpanel;
    AMQPComm *amqp;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AMQPComm *amqp;



@end
