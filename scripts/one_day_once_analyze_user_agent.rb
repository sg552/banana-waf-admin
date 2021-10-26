
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails'
require 'rubygems'

require 'net/http'
require 'json'

# 运行这个程序之前
# 一个access_key  每个月免费请求10000次

def analyze device
  params = {
    :access_key => "dd05a2a139918d8e3932e36d68875443",
    :ua => device.user_agent
  }
  begin
    $logger.info "====开始请求接口"
    uri = URI('http://api.userstack.com/detect')
    uri.query = URI.encode_www_form(params)
    $logger.info "==== uri: #{uri.inspect}"
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)

    $logger.info result["ua"]
    # 品牌
    brand = result["brand"].to_s
    # 品牌名称
    brand_name = result["name"].to_s
    ua_type = result["type"].to_s
    $logger.info "品牌信息"
    $logger.info "类型：#{ua_type}"
    $logger.info "品牌：#{brand}"
    $logger.info "品牌名称：#{brand_name}"

    device.ua_type = ua_type
    device.brand = brand
    device.brand_name = brand_name

    # os
    os = result["os"]
    os_name = os["name"]
    os_code = os["code"]
    family = os["family"] #Android
    family_code = os["family_code"]
    family_vendor = os["family_vendor"]
    os_icon_large = os["icon_large"]
    os_url = os["url"]

    $logger.info "操作系统信息"
    $logger.info "操作系统名称：#{os_name}"
    $logger.info "操作系统代码：#{os_code}"
    $logger.info "操作系统系列：#{family}"
    $logger.info "操作系统系列代码：#{family_code}"
    $logger.info "供应商：#{family_vendor}"
    $logger.info "操作系统官网：#{os_url}"
    $logger.info "操作系统icon：#{os_icon_large}"

    device.os_name = os_name || ''
    device.os_code = os_code || ''
    device.os_family = family || ''
    device.os_family_code = family_code || ''
    device.os_family_vendor = family_vendor || ''
    device.os_url = os_url || ''
    device.os_icon = os_icon_large || ''

    # device
    device_info = result["device"]

    is_mobile_device = device_info["is_mobile_device"]
    device_brand = device_info["brand"]  # Xiaomi
    device_brand_code = device_info["brand_code"] # xiaomi
    device_brand_url = device_info["brand_url"] # http://www.mi.com/
    device_name = device_info["name"] # Redmi Note 8 Pro
    device_type = device_info["type"]

    $logger.info "设备信息"
    $logger.info "设备类型：#{device_type}"
    $logger.info "是不是移动设备：#{is_mobile_device}"
    $logger.info "设备品牌：#{device_brand}"
    $logger.info "设备品牌代码：#{device_brand_code}"
    $logger.info "设备品牌官网：#{device_brand_url}"
    $logger.info "设备名称：#{device_name}"

    device.is_mobile = is_mobile_device
    device.device_type = device_type|| ''
    device.device_brand = device_brand|| ''
    device.device_brand_code = device_brand_code|| ''
    device.device_brand_url = device_brand_url|| ''
    device.device_name = device_name|| ''

    # browser
    browser = result["browser"]
    browser_name = browser["name"] # Android webview
    browser_version = browser["version"] #
    browser_version_major = browser["version_major"] #
    browser_engine = browser["engine"] #

    $logger.info "浏览器信息"
    $logger.info "浏览器名称：#{browser_name}"
    $logger.info "浏览器版本：#{browser_version_major}"
    $logger.info "浏览器主板本：#{browser_version_major}"
    $logger.info "浏览器引擎：#{browser_engine}"

    device.browser_name = browser_name|| ''
    device.browser_version = browser_version|| ''
    device.browser_version_major = browser_version_major|| ''
    device.browser_engine = browser_engine|| ''


    # crawler 爬虫
    crawler = result["crawler"]
    is_crawler = crawler["is_crawler"]
    crawler_category = crawler["category"]
    crawler_last_seen =  crawler["last_seen"]

    $logger.info "是否爬虫：#{is_crawler}"

    device.is_crawler = is_crawler
    device.crawler_category = crawler_category|| ''
    device.crawler_last_seen = crawler_last_seen|| ''

    device.is_analyzed = true
    device.save!
  rescue Exception =>e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
  end

end

loop do
  devices = Device.where("is_analyzed = ?", false)
  $logger.info "处理数据个数 #{devices.count}"
  devices.each do |device|
    analyze device
    sleep 10
  end
  sleep 60
end
