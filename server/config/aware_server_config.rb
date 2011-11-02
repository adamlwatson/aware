require 'ostruct'
require 'yaml'

require File.join(File.dirname(__FILE__), 'app/models/mongo/mongo_model_base')
require File.join(File.dirname(__FILE__), 'app/models/sql/sql_model_base')

# shared config values
config['api_version'] = 1

config['db_connection_pool_size'] = 20
config['mongo_connection_pool_size'] = 20
config['memcache_connection_pool_size'] = 20

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
MongoModelBase::set_db_pool(config['mongo'])

# set up reference to our config object in the sql base model class
SqlModelBase::config = config

