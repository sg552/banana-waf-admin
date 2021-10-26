require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'

loop do 
	$logger.info "start"
  Ip.where("attribution is null or attribution = ?", '未知').each do |ip_obt|
  	$logger.info ip_obt
  	sleep 1.5
  	ip_obt.update!(attribution: IpOwnership.new(ip: ip_obt.ip_address).get_url)
  end
	$logger.info "end"
	sleep 60 * 2
end