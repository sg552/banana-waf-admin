require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'

Ip.find_in_batches(start: 0, finish: 200000, batch_size: 200000) do |ips|
	# p ips
	ips.each do |ip|
		UserBehavier.select("DISTINCT member_id").where(ip: ip.ip_address).each do |u|
			p ip
			IpForMember.find_or_create_by(ip_id: ip.id, member_id: u.member_id) if !u.member_id.present? || u.member_id != 0
		end
	end
end
