require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'
require 'json'

@key_in_redis = "lua_record_user_behavior"
loop do
  behaviers = $redis.smembers @key_in_redis
  $logger.info "====== one loop start"
  $logger.info "======find behaviers count = #{behaviers.count}"
  p '找到了记录'
  p behaviers.count
  behaviers.each do |ori_behavier|
    behavier = JSON.parse(ori_behavier)
    $logger.info behavier
    action_ip =  behavier['ip'] || ''
    host = behavier['host'] || ''
    uri = behavier['uri'] || ''
    time = behavier['time'] || ''
    para = behavier['params'] || ''
    header = behavier['req_headers'] || ''
    http_method = behavier['http_method'] || ''

    # get cookie and user-agent from headers
    cookie = header['cookie'] || ''
    user_agent = header['user-agent'] || ''

    if para['public_key'].present?
      m = Member.find_by_public_key para['public_key']
      member_id = m.id if m.present?
    elsif cookie['st'].present?
      cook = CGI::parse(cookie)
      st = cook[' st'].first
      member_id = (DataKeeper.get(st) rescue nil)
    end

    behavier_id = 0
    behavier = Behavier.find_by_url uri
    if behavier.present?
      behavier_id = behavier.id
    end
    begin

      #user_agent 处理
      if user_agent.present?
        device = Device.find_by_user_agent user_agent
        if device.blank?
         device = Device.create! user_agent: user_agent
        end
      end

      if device.present?
        device_id = device.id
      else
        device_id = 0
      end

      ip_table = Ip.find_or_create_by(ip_address: action_ip.to_s)
      if member_id.present?
        ip_form_member = IpForMember.where(ip_id: ip_table.id, member_id: member_id.to_i)
        if ip_form_member.empty?
          ip_form_member.create!(ip_id: ip_table.id, member_id: member_id.to_i)
          ip_table.update!(count: (ip_table.count.to_i + 1))
          ip_table.update_friendly
        end
      end
      host_table = Host.find_or_create_by(name: host)

      $logger.info "======device_id == #{device_id}"
      $logger.info "======ip_id== #{ip_table.id}"
      UserBehavier.create!({
        ip_id: ip_table.id,
        member_id: (member_id.present? ? member_id : 0),
        time: time,
        behavier_id: behavier_id,
        params_text: para.to_s,
        cookie: cookie,
        device_id: device_id,
        uri: uri,
        http_method: http_method,
        # host: host,
        host_id: host_table.id
      })

      $redis.srem @key_in_redis, ori_behavier
      $logger.info "=====after create behavier ip == #{action_ip} success"

    rescue Exception => e
      $logger.info e.inspect
    end
  end
  $logger.info "====== one loop end"
  sleep 10
end
