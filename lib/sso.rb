class Sso
  class << self
    def faraday_instance
      Faraday.new("#{ENV['GLY_API_SERVER']}")
    end

    def service_st_ticket_validate ticket
      response = faraday_instance.post '/api/v2/cas/service_st_ticket_validate', {ticket: ticket}
      JSON(response.body)
    end

    def service_st_cookie_validate st
      response = faraday_instance.post '/api/v2/cas/service_st_cookie_validate', {st: st}
      JSON(response.body)
    end

    def sign_out st
      response = faraday_instance.post('/api/v2/cas/sign_out') do |req|
        req.body = { "server_ticket": st }
      end
      JSON(response.body)
    end

  end
end