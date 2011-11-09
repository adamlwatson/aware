
###
### AMQP connection
###


amqp_login = {
  :host => 'localhost',
  :user => 'guest',
  :pass => 'guest'
}

config['amqp_conn'] = AMQP.connect(amqp_login)
config['amqp_channel'] = AMQP::Channel.new(config['amqp_conn'])



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


