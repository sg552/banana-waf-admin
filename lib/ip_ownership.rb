class IpOwnership
  def initialize option
    @url = ENV["GET_IP_OWNERSHIP_URL"]
    @ip = option[:ip]
  end

  def get_url
    ownership = "未知"
    response = HTTParty.get("#{@url}/#{@ip}?lang=zh-CN")
    if response.parsed_response && response.parsed_response["status"] == 'success'
      ownership = "#{response.parsed_response["country"]}/#{response.parsed_response["regionName"]}/#{response.parsed_response["city"]}"
    end
    ownership
  end

end