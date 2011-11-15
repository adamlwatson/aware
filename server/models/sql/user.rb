require 'models/sql/sql_model_base'

class User < SqlModelBase

  #attr_accessor :id, :gamertag, :email, :phone_number, :url, :motto, :description, :badge_id
  #              :crypted_password, :salt, :created_at, :updated_at, :activation_code, :activated_at
  #              :state, :deleted_at, :flags_count, :buddies_count, :tweet, :tweeted_at
  #              :email_hash, :reset_code, :photo_file_name, :photo_content_type, :photo_file_size
  #              :photo_updated_at, :first_name, :last_name, :fullname_privacy, :gamerscore
  #              :age_group, :age_restricted, :opt_in, :device_token, :social_photo_url

  def initialize()
    @cache_key = "USER"
    @cache_key_version = "A"
    @table = "users"
    @fields = []
  end


# note: you could create methods like the ones below...  but why? :)
# instead, you can rely on the dynamic finder methods for simple queries
# see SqlModelBase::method_missing()
=begin
  def find_by_id(val)
    #expiration = 60
    qry = "SELECT * from #{@table} where id = #{val}"
    rows = query_with_cache(qry, 'id', id)
    prepare_result rows[:value]
  end


  def find_by_product_id(val)
    qry = "SELECT * from #{@table} where product_id = #{val}"
    rows = query_with_cache(qry, 'product_id', val)
    prepare_result rows[:value]
  end
=end


end