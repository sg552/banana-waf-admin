require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'
require 'rufus/scheduler'

@reason_key_in_redis = "lua_blocked_reason"
@manager = Manager.first

scheduler = Rufus::Scheduler.new

def run
  BlockedIp.transaction do
    ips_in_redis = $redis.smembers 'lua_blocked_ips'
    ips_in_redis.each do |ip|
      ip_in_mysql = BlockedIp.find_by_ip ip
      if ip_in_mysql.blank?
        reason_key = @reason_key_in_redis + ip
        reason = $redis.hget(reason_key, 'reason' ) || ''
        comment = $redis.hget(reason_key, 'comment') || ''
        time = $redis.hget(reason_key, 'time') || ''
        begin
          BlockedIp.create! ip: ip,
            blocked_by: @manager.id,
            blocked_reason: reason,
            comment: comment,
            created_at: time
        rescue
          BlockedIp.create! ip: ip,
            blocked_by: @manager.id,
            blocked_reason: reason,
            comment: '二进制类消息，需要数据库的重启才行，所以暂不记录了',
            created_at: time
        end
      end
    end
  end
end

scheduler.every '10s' do
  run
end

scheduler.join
# run
