require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'
require 'json'

p '只运行一次就行 多次运行也不影响啥'
p '运行完后 删掉Userbehavier 中的 user-agent列'
p '==='
devices = UserBehavier.select(:user_agent).distinct
p "找到了 #{devices.count}"
devices.each do |device|
  p device.user_agent
  d = Device.find_or_create_by user_agent: device.user_agent
  if d.present?
   a = UserBehavier.where("user_agent = ?", device.user_agent)
   a.update_all(device_id: d.id)
  end
end
