class BlockedIp < ApplicationRecord

  belongs_to :blocked_manager, :foreign_key => 'blocked_by', :class_name => 'Manager'
  belongs_to :unblocked_manager, :foreign_key => 'unblocked_by', :class_name => 'Manager'

  after_commit :create_or_destory_in_redis, :on => [:create, :update]
  after_commit :destory_in_redis, :on => :destroy

  after_create :set_blocked_ip_statistical_analysis


 after_create :write_ip_table

  YUNPIAN_URL = URI.parse(ENV['SMS_URL'])
  SMS_TEMPLATE = "【#{ENV['SMS_SIGNATURE']}】有新的IP%s被封禁，请尽快处理"

  def write_ip_table
    Ip.find_or_create_by(ip_address: self.ip)
  end


  def get_comment
    comm = self.comment
    if comm.present?
      comm = comm.lstrip
    end
    comm
  end
  #blocked_manager

  def get_key
    "lua_blocked_ips"
  end

  def destory_in_redis
      $redis.srem get_key, self.ip
      $redis.del("lua_blocked_reason" + self.ip)
  end

  def create_or_destory_in_redis
    if self.is_blocked
      $redis.sadd get_key, self.ip
    else
      destory_in_redis
    end
  end

  def set_blocked_ip_statistical_analysis
    blocked_ips = $redis.get("blocked_ip")
  end

end
