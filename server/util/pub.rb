#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "util_helper")

# no queue name = bind to exchange
@queue_name = "stream.one"
@exchange_name = "aware.fanout"
@channel_num = 1


init_util "subscribe and basic ack" do |client|
  channel = AMQ::Client::Channel.new(client, @channel_num)
  channel.open do
    puts "Channel #{channel.id} is now open!"
  end

  queue = AMQ::Client::Queue.new(client, channel, @queue_name)
  queue.declare

  queue.bind(@exchange_name) do
    puts "Queue #{queue.name} is now bound to #{@exchange_name}"
  end

  exchange = AMQ::Client::Exchange.new(client, channel, @exchange_name, :fanout)
  count = 0
  EM.add_timer(1) do
    exchange.publish("Message: #{count}")
    count += 1
  end

  show_stopper = Proc.new {
    client.disconnect do
      puts
      puts "AMQP connection is now properly closed"
      EventMachine.stop
    end
  }

  Signal.trap "INT", show_stopper
  Signal.trap "TERM", show_stopper

  #EM.add_timer(1, show_stopper)
end