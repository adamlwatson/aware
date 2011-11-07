=begin
# for non-blocking direct sql db connections
require 'mysql2/em_fiber'
config['db'] = EM::Synchrony::ConnectionPool.new(:size => config['db_connection_pool_size']) do
  ::Mysql2::EM::Fiber::Client.new(:host => 'localhost',
                                  :username => 'root',
                                  :password => 'toor',
                                  :database => 'aware_development',
                                  :socket => nil,
                                  :reconnect => true
                                  )
end

=end

#
# memcached connection pool
#

require 'em-synchrony/em-remcached'

config['memcache'] = EM::Synchrony::ConnectionPool.new(size:config['memcache_connection_pool_size']) do
  conn = Memcached.connect %w(localhost:11211)
end


###
### mongo db direct connection
###

require 'em-synchrony/em-mongo'
require 'mongoid'

config['mongo'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
  conn = EM::Mongo::Connection.new('localhost', 27017, 1, {:reconnect_in => 1})
  conn.db('aware_development')
end

# mongoid setup - all access is synchronous
mongoid_conn = Mongo::Connection.new 'localhost', 27017, :pool_size => config['mongo_connection_pool_size']
Mongoid.configure do |config|
  config.master = mongoid_conn.db('aware_development')
end




###
### streaming / amqp server connections
###

require 'amqp'

config['channel'] = EM::Channel.new

config['amqp'] = {
  :host => 'localhost',
  :user => 'guest',
  :pass => 'guest'
}

conn = AMQP.connect(config['amqp'])
channel = AMQP::Channel.new(conn)

x = channel.fanout("aware.fanout")
q1 = channel.queue("stream.one").bind(x, :routing_key => "")
#q2 = channel.queue("stream.two").bind(x, :routing_key => "stream.two")
#q3 = channel.queue("stream.global").bind(x, :routing_key => "stream.#")

# push data into the stream. (Just so we have stuff going in)
puts "publishing to exchange: #{x}"

count = 0
EM.add_periodic_timer(2) do
  x.publish "Message #{count}\n"
  #x.publish "two #{count}\n", :routing_key => "stream.two"
  #x.publish "global #{count}\n", :routing_key => "stream.#"
  count += 1
end


# push to http clients...
#q3.subscribe(&method(:handle_message))
def handle_message(meta, data)
  config['channel'].push(data)
end



