class DataKeeper
  extend RedisExtend
  cattr_accessor :redis
  class << self
    def redis_instance
      if @@redis.blank?
        $logger.info ENV['PC_MEMBER_REDIS_URL']
        @@redis = Redis.new url: ENV['PC_MEMBER_REDIS_URL']
      end
      @@redis
    end

     # 有效时间time(单位: 秒) 默认一天
    def set(key, value, time=86400)
      key_and_value_valid? key, value
      redis_instance.set(key, value, ex: time)
    end

    #无限有效期
    def set_forever(key, value)
      key_and_value_valid? key,value
      redis_instance.set(key, value)
    end
  end

end
