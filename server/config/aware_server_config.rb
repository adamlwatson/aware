require 'amqp'
require 'yajl'

require File.join(File.dirname(__FILE__), 'models/mongo/mongo_model_base')
require File.join(File.dirname(__FILE__), 'models/sql/sql_model_base')

# shared config values
config['api_version'] = 1

config['db_connection_pool_size'] = 5
config['mongo_connection_pool_size'] = 5
config['memcache_connection_pool_size'] = 5

config['channel'] = EM::Channel.new


#env.logger.info("requiring " +  Goliath.env.to_s)

import(File.join(File.dirname(__FILE__), Goliath.env.to_s))

environment :production do
end

environment :development do
  require 'ruby-debug'
end

environment :test do
  require 'ruby-debug'
end

environment :staging do
end

# set up reference to our mongo db connection pool in the mongo base model class
MongoModelBase::config = config

# set up reference to our config object in the sql base model class
SqlModelBase::config = config


##
## Exchanges
##
puts '** setting up exchanges...'
config['amqp_x'] = {}
config['amqp_q'] = {}

# set up amqp broadcast exchange. All clients bind and subscribe.
config['amqp_x']['aware.system.fanout'] = config['amqp_channel'].fanout("aware.system.fanout", {:passive => false, :durable => true, :auto_delete => false})
#puts "[amqp] exchange aware.system.fanout: #{config['amqp_x']['aware.system.fanout']}"

# set up system-in exchange. All clients bind and publish/subscribe.
config['amqp_x']['aware.system.comm'] = config['amqp_channel'].topic("aware.system.comm", {:passive => false, :durable => true, :auto_delete => false})
#puts "[amqp] exchange aware.system.comm: #{config['amqp_x']['aware.system.comm']}"



##
## Incoming Sys Comm Queue
##

exch = config['amqp_x']['aware.system.comm']
sysq = config['amqp_q']['aware.system.comm'] = AMQP::Queue.new(config['amqp_channel'], "aware.system.comm",  {:passive => false, :durable => true, :auto_delete => false})

#aware.system.comm.#
sysq.bind(exch, :routing_key =>"#").subscribe do |headers, payload|
  handle_message headers, payload
end

def handle_message headers, payload

  # payload
  msg = Yajl::Parser.parse(payload)

  case msg["msg_type"]
    when "heartbeat"
      handle_heartbeat msg, headers
    when "connect"
      handle_connect_client msg, headers
    when "disconnect"
      handle_disconnect_client msg, headers
    when "location_update"
      handle_location_update msg, headers
  end

end


##
## Sys Comm Queue -- Message Handlers
##

def handle_heartbeat msg, headers
  puts "heartbeat: #{msg}. routing key: #{headers.routing_key}"
end

def handle_connect_client msg, headers
  # send back list of users nearby so client can subscribe to their location update queues
  puts "connect: #{msg}. routing key: #{headers.routing_key}"

end

def handle_disconnect_client msg, headers
  # notify connected clients and drop
  puts "disconnect: #{msg}. routing key: #{headers.routing_key}"
end

def handle_location_update msg, headers
  puts "location: #{msg}. routing key: #{headers.routing_key}"
end


##
## Heartbeat
##

puts "** beginning amqp heartbeat on 'aware.system.fanout': #{config['aware.system.fanout']}"
EM.add_periodic_timer(5) do
  send_heartbeat
  #puts '*** [publishing broadcast]'
  #x.publish "two #{count}\n", :routing_key => "stream.two"
  #x.publish "global #{count}\n", :routing_key => "stream.#"
end

def send_heartbeat
  msg = {"msg_type" => "heartbeat", "timestamp" => Time.now.to_s, "udid" => "SERVER-0"}
  json = Yajl::Encoder.encode(msg)
  config['amqp_x']['aware.system.comm'].publish json, :routing_key => "aware.system.comm.broadcast"

end


count = 0
#EM.add_periodic_timer(2) do
#  count += 1
#  config['aware.system.comm'].publish "aware syscomm #{count}\n", :routing_key => "aware.system.comm.7695c9cf9d4c6acfcda3a298068178ea"
#  #aware.system.comm.7695c9cf9d4c6acfcda3a298068178ea
#  #puts "[publishing comm #{count}]"
#  #x.publish "two #{count}\n", :routing_key => "stream.two"
#  #x.publish "global #{count}\n", :routing_key => "stream.#"
#end




##
## Bridge for HTTP persistent connections
##

# push to http clients...
#q3.subscribe(&method(:handle_message))

#def handle_message(meta, data)
#  config['channel'].push(data)
#end





stop_server = Proc.new do
  puts "[aware server] Stopping..."
  EM.stop { exit }
end

Signal.trap "INT", stop_server



