class HistoryIp < ApplicationRecord


	# 记录登陆者前一百次的登陆IP以及登陆时间
	def self.create_current_logged_information(manager_id, login_ip)
		HistoryIp.create({manager_id: manager_id, ip: login_ip, logged_at: Time.now})
	end
end
