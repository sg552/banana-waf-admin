require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'

UserBehavier.where("host_id is null").find_in_batches(start: 200000, batch_size: 200000) do |ubs|
	$logger.info "start"
	ubs.each do |ub|
		host = Host.find_or_create_by(name: ub[:host])
		ub.update(host_id: host.id)
	end
	$logger.info "end"
end

	

