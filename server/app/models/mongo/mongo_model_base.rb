require 'helpers/cache_helper'

class MongoModelBase
  include CacheHelper

  @@mongo = nil

  def self.set_db_pool(pool)
    @@mongo = pool
  end

  def self.config=(config)
    @@config = config
  end

  def config
    @@config
  end

  def db
    @@config['mongo']
  end

  def memcache
    @@config['memcache']
  end

  def env
    @@config['env']
  end

  def fields=(fields)
    unless fields.is_a?Array
      raise("SqlModelBase::fields= must be passed an Array of field names as Strings.")
    end
    @fields = fields.sort
  end

  def query_with_cache(qry, cache_key_name, id, ttl = nil)
    read_cached(gen_cache_key(cache_key_name, id, ttl)) do
      arr = []
      db.query(qry).each do |row|
        arr.push(row)
      end
      arr
    end
  end

  # return @fields formatted for use as field selectors in a sql query
  def formatted_fields
    all_fields = ""
    @fields.each do |piece|
      all_fields += piece + ","
    end
    all_fields.chop!
  end

  # only return result hash of keys present in @fields
  def prepare_result(res)
    hashes = []
    if (@fields.count == 0)
      hashes = res
    else
      res.each do |r|
        hash = {}
        @fields.each do |field|
          if r.has_key?field
            hash[field] = r[field]
          end
        end
        hashes.push(hash)
      end
    end

    # only return array if more that one result row is present
    if hashes.count == 1
      hashes[0]
    else
      hashes
    end
  end

  # handles all simple queries on single ids ie ( find_by_xxx(yyy) )
  # args[0] should be the value of the key being queried in the where clause
  # args[1] (optional) should be the ttl of the resulting memcache object that is possibly created
  def method_missing(key, *args)
    keyname = nil
    case key.to_s
      when /^find_by_([_a-zA-Z]\w*)$/
        keyname = $1
      else
        raise("Dynamic finder for #{key}/#{args} found no match.")
        return
    end
    val = args[0]
    qry = "SELECT * from #{@table} where #{keyname} = #{val}"

    if ( (args.count > 1) && (args.is_a?(Numeric)) )
      ttl = args[1]
      rows = query_with_cache(qry, keyname, val, ttl)
    else
      rows = query_with_cache(qry, keyname, val)
    end

    prepare_result rows[:value]
  end
end