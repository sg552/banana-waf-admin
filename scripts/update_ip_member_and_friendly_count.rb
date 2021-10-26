require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'

Ip.all.each do |ip|

	ip_form_member = IpForMember.where(ip_id: ip.id)

  count = ip_form_member.select("DISTINCT member_id").count
  member_id_arr = ip_form_member.pluck(:member_id).uniq
 
  real_name_member_count = Member.where(id: member_id_arr).where("real_name is not null and real_name != ?", "").count

  query = {count: count}
  query.merge!({friendly: (real_name_member_count.to_f / count).floor(2)}) if count != 0
  ip.update!(query)
end