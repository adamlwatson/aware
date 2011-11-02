require 'app/models/mongo/mongo_model_base'

class Location < MongoModelBase


  def initialize
    @cache_key = "USER"
    @cache_key_version = "A"
    @table = "users"
    @fields = []
  end


end