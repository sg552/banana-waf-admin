class Behavier < ApplicationRecord
  has_many :url_visit_limits

  after_commit :create_or_update_in_redis, :on => [:create, :update]
  after_commit :destory_in_redis, :on => :destroy

  ENABLE = 'enable'

  def get_key
    "lua_" + self.url
  end

  def create_or_update_in_redis
    $redis.hset get_key, ENABLE, 1
  end

  def destory_in_redis
    is_ebable = $redis.hexists get_key, ENABLE
    if is_ebable
      $redis.del get_key
    end
  end

end
