require 'models/mongo/mongo_model_base'

class User < MongoModelBase


  def initialize
    @cache_key = "USER"
    @cache_key_version = "A"
    @table = "users"
    @fields = []
  end


end