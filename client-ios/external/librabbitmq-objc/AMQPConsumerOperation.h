//
//  AMQPConsumerThread.h
//  Objective-C wrapper for librabbitmq-c
//
//  Copyright 2009 Max Wolter. All rights reserved.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

//#import <Cocoa/Cocoa.h>

#import <UIKit/UIKit.h>

#import "AMQPConsumerOperationDelegate.h"

@class AMQPConnection;
@class AMQPChannel;
@class AMQPQueue;
@class AMQPConsumer;
@class AMQPMessage;

@interface AMQPConsumerOperation : NSOperation
{
	AMQPConsumer *consumer;
	NSObject<AMQPConsumerOperationDelegate> *delegate;
}

@property (assign) NSObject<AMQPConsumerOperationDelegate> *delegate;


- (id)initWithConsumer:(AMQPConsumer*)theConsumer;
- (void)dealloc;
- (void)main;
- (BOOL)isConcurrent;

@end
