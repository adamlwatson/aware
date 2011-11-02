require 'yajl'

module CacheHelper
  CACHE_KEY_DELIM = ':'
  DEFAULT_EXPIRE_TIME = 86400 # default to persist for 24 HOURS

  def self.included(base)
    #@encoder = Yajl::Encoder.new
  end

  # given key, tries to pull value from cache and return it as a hash.
  # takes a proc that is the method used to retrieve the value from whatever backend store is being used
  # if key is not found, tries to cache before returning value
  # if all else fails, just returns the raw result hash

  # returns a result hash with these keys:
  # value: resultant value as a hash
  # get_err: get return code
  # set_err: set return code or nil

  def read_cached(key, ttl = nil)

    if memcache.usable?
      if (ttl == nil)
        ttl = DEFAULT_EXPIRE_TIME
      end
      get_result = memcache.get(key: key)
      case get_result[:status]

        when Memcached::Errors::NO_ERROR
          # parse return value from cache into a hash and return it
          hash = Yajl::Parser.new.parse(get_result[:value])
          return_val(hash, get_result[:status], nil)

        when Memcached::Errors::KEY_NOT_FOUND
          # populate memcache with json version of the hash result, return hash result
          result = yield
          json = Yajl::Encoder.new.encode(result)
          set_result = memcache.set(key: key, value: json, expiration: ttl)
          return_val(result, get_result[:status], set_result[:status])

        else
          # Memcached::Errors::DISCONNECTED, etc
          # return uncached hash value...
          result = yield
          return_val(result, get_result[:status], nil)
      end

    else
      # return uncached hash value
      result = yield
      return_val(result, nil, nil)
    end

  end

  # returns a prefix for the cache key for this class
  def cache_key_prefix
    @cache_key + CACHE_KEY_DELIM + @cache_key_version
  end

  # generates a cache key based on class cache key prefix and any suffix args passed in
  def gen_cache_key(*args)
    key = cache_key_prefix
    args.each do |arg|
      key += CACHE_KEY_DELIM + arg.to_s.upcase
    end
    #puts "memcache key: #{key}"
    key
  end

  private

  def return_val(value, get_code, set_code)
    {:value => value, :get_code => get_code, :set_code => set_code}
  end

end


