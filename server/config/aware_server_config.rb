require 'amqp'
#require 'ostruct'
#require 'yaml'

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


# set up amqp broadcast exchange. All clients bind and subscribe.
config['aware.system.fanout'] = config['amqp_channel'].fanout("aware.system.fanout", {:passive => false, :durable => true, :auto_delete => false})
puts "[amqp] aware.system.fanout: #{config['aware.system.fanout']}"

# set up system-in exchange. All clients bind and publish/subscribe.
config['aware.system.comm'] = config['amqp_channel'].direct("aware.system.comm", {:passive => false, :durable => true, :auto_delete => false})
puts "[amqp] aware.system.comm: #{config['aware.system.comm']}"

puts "** beginning amqp heartbeat on 'aware.system.fanout': #{config['aware.system.fanout']}"
EM.add_periodic_timer(5) do
  config['aware.system.fanout'].publish "aware heartbeat #{Time.new}\n"
  #puts '*** [publishing broadcast]'
  #x.publish "two #{count}\n", :routing_key => "stream.two"
  #x.publish "global #{count}\n", :routing_key => "stream.#"
end

count = 0
EM.add_periodic_timer(2) do
  count += 1
  config['aware.system.comm'].publish "aware syscomm #{count}\n", :routing_key => "aware.system.comm.7695c9cf9d4c6acfcda3a298068178ea"
  #aware.system.comm.7695c9cf9d4c6acfcda3a298068178ea
  #puts "[publishing comm #{count}]"
  #x.publish "two #{count}\n", :routing_key => "stream.two"
  #x.publish "global #{count}\n", :routing_key => "stream.#"
end

# push to http clients...
#q3.subscribe(&method(:handle_message))
def handle_message(meta, data)
  config['channel'].push(data)
end



