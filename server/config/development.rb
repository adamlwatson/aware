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


#
# mongo db direct connection
#

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



