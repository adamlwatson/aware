
###
### AMQP connection
###


config['amqp'] = {
  :host => 'localhost',
  :user => 'guest',
  :pass => 'guest'
}

#
# memcached connection pool
#

require 'em-synchrony/em-remcached'

config['memcache'] = EM::Synchrony::ConnectionPool.new(size:config['memcache_connection_pool_size']) do
  conn = Memcached.connect %w(10.1.202.120:11211, 10.1.202.121:11211, 10.1.202.122:11211, 10.1.202.123:11211, 10.1.202.124:11211, 10.1.202.125:11211, 10.1.202.126:11211, 10.1.202.127:11211, 10.1.202.128:11211, 10.1.202.129:11211)
end


# mongo db connection
require 'em-synchrony/em-mongo'
require 'mongoid'

config['mongo'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
  conn = EM::Mongo::Connection.new('', 27017, 1, {:reconnect_in => 1})
  conn.db('mobage_development')
end


# mongoid setup...  all access is synchronous

#config['mongoid'] = EM::Synchrony::ConnectionPool.new(size:config['mongo_connection_pool_size']) do
mongoid_conn = Mongo::Connection.new '', 27017, :pool_size => config['mongo_connection_pool_size']
Mongoid.configure do |config|
  config.master = mongoid_conn.db('mobage_development')
end
#end

