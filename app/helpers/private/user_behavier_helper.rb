module Private::UserBehavierHelper

  def ip_infomation(ip)
    "IP: #{ip.ip_address rescue '--'}<br>\
     地址: #{ip.attribution rescue '--'}<br>\
     友善度: #{ip.try(:friendly).to_d*100}%<br>".html_safe
  end

  def device_detail(device)
    "类型: #{device.ua_type rescue '--'}<br>\
     品牌: #{device.brand rescue '--'}<br>\
     名称: #{device.brand_name rescue '--'}<br>".html_safe
  end
end