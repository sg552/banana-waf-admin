class UrlVisitLimit < ApplicationRecord

  belongs_to :behavier

  TIMES_KEY = 'lua_max_times'
  TIME_KEY = 'lua_unit_time'

  after_commit :create_or_update_in_redis, :on => [:create, :update]
  after_commit :destory_in_redis, :on => :destroy

  def get_key
    "lua_" + self.behavier.url
  end

  def create_or_update_in_redis
    $logger.info get_key
    $logger.info self.maximum_times
    $logger.info self.duration
    $redis.hset get_key, TIMES_KEY, self.maximum_times
    $redis.hset get_key, TIME_KEY, self.duration
  end

  def destory_in_redis
    is_exists_times = $redis.hexists get_key, TIMES_KEY
    is_exists_time = $redis.hexists get_key, TIME_KEY
    if is_exists_times || is_exists_time
      $redis.del get_key
    end
  end

end
