//
//  AMQPQueue.m
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

#import "AMQPQueue.h"

# import <amqp.h>
# import <amqp_framing.h>

# import "AMQPChannel.h"
# import "AMQPExchange.h"
# import "AMQPConsumer.h"

@implementation AMQPQueue

@synthesize internalQueue = queueName;

- (id)initWithName:(NSString*)theName onChannel:(AMQPChannel*)theChannel isPassive:(BOOL)passive isExclusive:(BOOL)exclusive isDurable:(BOOL)durable autoDelete:(BOOL)autoDelete
{
	if(self = [super init])
	{
		amqp_queue_declare_ok_t *declaration = amqp_queue_declare(theChannel.connection.internalConnection, theChannel.internalChannel, amqp_cstring_bytes([theName UTF8String]), passive, durable, exclusive, autoDelete, AMQP_EMPTY_TABLE);
		
		[theChannel.connection checkLastOperation:@"Failed to declare queue"];
		
		queueName = amqp_bytes_malloc_dup(declaration->queue);
		channel = [theChannel retain];
	}
	
	return self;
}
- (void)dealloc
{
	amqp_bytes_free(queueName);
	[channel release];
	
	[super dealloc];
}

- (void)bindToExchange:(AMQPExchange*)theExchange withKey:(NSString*)bindingKey
{
	amqp_queue_bind(channel.connection.internalConnection, channel.internalChannel, queueName, theExchange.internalExchange, amqp_cstring_bytes([bindingKey UTF8String]), AMQP_EMPTY_TABLE);
	
	[channel.connection checkLastOperation:@"Failed to bind queue to exchange"];
}
- (void)unbindFromExchange:(AMQPExchange*)theExchange withKey:(NSString*)bindingKey
{
	amqp_queue_unbind(channel.connection.internalConnection, channel.internalChannel, queueName, theExchange.internalExchange, amqp_cstring_bytes([bindingKey UTF8String]), AMQP_EMPTY_TABLE);
	
	[channel.connection checkLastOperation:@"Failed to unbind queue from exchange"];
}

- (void)purge
{
    amqp_queue_purge(channel.connection.internalConnection, channel.internalChannel, queueName);
	[channel.connection checkLastOperation:@"Failed to purge queue"];
}

- (void)deleteIfUnused: (BOOL)ifUnused ifEmpty:(BOOL)ifEmpty
{
    amqp_queue_delete(channel.connection.internalConnection, channel.internalChannel, queueName, ifUnused, ifEmpty);
	[channel.connection checkLastOperation:@"Failed to delete queue"];
}

// delete unconditionally
- (void)deleteQueue
{
    [self deleteIfUnused:false ifEmpty:false];
}

- (AMQPConsumer*)startConsumerWithAcks:(BOOL)ack isExclusive:(BOOL)exclusive receiveLocal:(BOOL)local
{
	AMQPConsumer *consumer = [[AMQPConsumer alloc] initForQueue:self onChannel:channel useAcknowledgements:ack isExclusive:exclusive receiveLocalMessages:local];
	
	return [consumer autorelease];
}

@end
