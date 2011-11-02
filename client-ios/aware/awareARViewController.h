//
//  awareARViewController.h
//  aware
//
//  Created by Adam Watson on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface awareARViewController : UIViewController

@property (nonatomic, strong) NSArray *placesOfInterest;

- (void) updateLocations;
@end
