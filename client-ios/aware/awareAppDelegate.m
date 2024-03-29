//
//  awareAppDelegate.m
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "Constants.h"

#import "awareAppDelegate.h"
#import "awareARViewController.h"

#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "AMQPWrapper.h"

@implementation awareAppDelegate

@synthesize window = _window;
//@synthesize viewController = _viewController;

@synthesize amqp;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //dev token - TODO: constantize this based on build type
    mixpanel = [MixpanelAPI sharedAPIWithToken:(kMixpanelAPIToken)];
    
    DLog(@"** Device UDID: %@", [[UIDevice currentDevice] uniqueDeviceIdentifier] );
    DLog(@"** Global Device UDID: %@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier] );
    
    return YES;
}
	

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

    DLog(@"applicationDidEnterBackground()");
    
    //Disconnect from amqp server
    amqp = [AMQPComm sharedInstance];
    
    if ( [amqp isConnected] == true )
    {
        [amqp sendDisconnectMessage];
        [amqp disconnect];
    }
    
    
    DLog(@"Stopping location messages and ar view updates from app delegate.");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_sending_location_updates" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_ar_view_updates" object:nil];


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    DLog(@"applicationWillEnterForeground()");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    amqp = [AMQPComm sharedInstance];
    
    if ( [amqp isConnected] == false )
    {
        [amqp connect];
        [amqp sendConnectMessage];
    }

    DLog(@"Starting location messages and ar view updates from app delegate.");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_sending_location_updates" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_ar_view_updates" object:nil];
    
    DLog(@"applicationDidBecomeActive()");    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */

    
    DLog(@"applicationWillTerminate()");
    
}





@end
