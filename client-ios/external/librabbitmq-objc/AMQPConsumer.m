//
//  AMQPConsumer.m
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

#import "AMQPConsumer.h"

# import <amqp.h>
# import <amqp_framing.h>
# import <string.h>
# import <stdlib.h>

# import "AMQPChannel.h"
# import "AMQPQueue.h"
# import "AMQPMessage.h"

@implementation AMQPConsumer

@synthesize internalConsumer = consumer;
@synthesize channel;
@synthesize queue;

- (id)initForQueue:(AMQPQueue*)theQueue onChannel:(AMQPChannel*)theChannel useAcknowledgements:(BOOL)ack isExclusive:(BOOL)exclusive receiveLocalMessages:(BOOL)local
{
	if(self = [super init])
	{
		channel = [theChannel retain];
		queue = [theQueue retain];
		
		amqp_basic_consume_ok_t *response = amqp_basic_consume(channel.connection.internalConnection, channel.internalChannel, queue.internalQueue, AMQP_EMPTY_BYTES, !local, !ack, exclusive, AMQP_EMPTY_TABLE);
        
		[channel.connection checkLastOperation:@"Failed to start consumer"];
		
		consumer = amqp_bytes_malloc_dup(response->consumer_tag);
	}
	
	return self;
}
- (void)dealloc
{
	amqp_bytes_free(consumer);
	[channel release];
	[queue release];
	
	[super dealloc];
}

- (AMQPMessage*)pop
{
	amqp_frame_t    frame;
	int             result;
	size_t          receivedBytes = 0;
	size_t          totalBytes = 0;
	amqp_bytes_t    body;
	amqp_basic_deliver_t    *delivery;
	amqp_basic_properties_t *props;
	
	AMQPMessage *message = nil;
	
    
	amqp_maybe_release_buffers(channel.connection.internalConnection);
        
	while(!message)
	{
		// a complete message delivery consists of at least three frames:
		
		// Frame #1: method frame with method basic.deliver
		result = amqp_simple_wait_frame(channel.connection.internalConnection, &frame);
        
        //printf("Result %d\n", result);
        //printf("Frame type %d, channel %d\n", frame.frame_type, frame.channel);
        
        if(result < 0) { return nil; }
		
		if(frame.frame_type != AMQP_FRAME_METHOD || frame.payload.method.id != AMQP_BASIC_DELIVER_METHOD) { continue; }
		
        //printf("Method %s\n", amqp_method_name(frame.payload.method.id));
        
		delivery = (amqp_basic_deliver_t *) frame.payload.method.decoded;
        
        //printf("Delivery %u, exchange %.*s routingkey %.*s\n", (unsigned) delivery->delivery_tag,(int) delivery->exchange.len, (char *) delivery->exchange.bytes,(int) delivery->routing_key.len, (char *) delivery->routing_key.bytes);

		// Frame #2: header frame containing body size
		result = amqp_simple_wait_frame(channel.connection.internalConnection, &frame);
		if(result < 0) { return nil; }
		
		if(frame.frame_type != AMQP_FRAME_HEADER)
		{
            //fprintf(stderr, "Expected header!");
			return nil;
		}
		
		props = (amqp_basic_properties_t*)frame.payload.properties.decoded;
		//printf("Content-type: %.*s\n", (int) props->content_type.len, (char *) props->content_type.bytes);
        
		totalBytes = frame.payload.properties.body_size;
		receivedBytes = 0;
		body = amqp_bytes_malloc(totalBytes);
		
		// Frame #3+: body frames
		while(receivedBytes < totalBytes)
		{
			result = amqp_simple_wait_frame(channel.connection.internalConnection, &frame);
			if(result < 0) { return nil; }
			
			if(frame.frame_type != AMQP_FRAME_BODY)
			{
                //fprintf(stderr, "Expected body!");
				return nil;
			}
			
			receivedBytes += frame.payload.body_fragment.len;
			
            memcpy(body.bytes, frame.payload.body_fragment.bytes, frame.payload.body_fragment.len);
            
		}
		
        if (receivedBytes != totalBytes) {
            /* Can only happen when amqp_simple_wait_frame returns <= 0 */
            /* We might want to break here to stop processing */
            //break;
        }
        NSLog(@"** acking message");
        amqp_basic_ack(channel.connection.internalConnection, 1, delivery->delivery_tag, 0);	

        message = [AMQPMessage messageFromBody:body withDeliveryProperties:delivery withMessageProperties:props receivedAt:[NSDate date]];
		
		amqp_bytes_free(body);
	}
	
	return message;
}

@end
