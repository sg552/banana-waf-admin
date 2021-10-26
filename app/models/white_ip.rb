class WhiteIp< ApplicationRecord

  after_commit :add_to_redis, :on => [:create, :update]
  after_commit :destory_from_redis, :on => :destroy
  before_save :ip_ownership

  def get_key
    "lua_white_ips"
  end

  def destory_from_redis
      $redis.srem get_key, self.ip
  end

  def add_to_redis
    unless $redis.sismember get_key, self.ip
       $redis.sadd get_key, self.ip
    end
  end

  def ip_ownership
    #ip_ownership = IpOwnership.new(ip: self.ip).get_url
    #self.ip_ownership = ip_ownership
  end

end
