class ApplicationController < ActionController::Base
  include LoggableController

  protect_from_forgery with: :exception
  before_action :current_login
  before_action :check_email_nil
  before_action :set_locale
  helper_method :current_manager

  def set_locale
    I18n.locale = cookies[:cadex_admin_lang] || 'zh'#SystemVariable.where(name: 'set_default_locale').first.try(:value)
    I18n.default_locale = I18n.locale
  end

  def current_login
    sign_in = "#{ENV['GLY_CAS_SERVER']}?lang=#{cookies[:otc_lang] || I18n.locale}&service=#{ ENV['MAIN_SERVER'] }"
    # 第一次登陆进来
    if params[:ticket].present?
      # s
      ticket_validate = Sso.service_st_ticket_validate params[:ticket]
      unless ticket_validate["code"] == 20000
        redirect_to sign_in and return
      end
      unless ticket_validate["expires"].to_i < 0
        set_cookie(params[:ticket], ticket_validate["expires"].to_i)
      end
      redirect_to root_path
    else
      cookie_validate = Sso.service_st_cookie_validate cookies[:st]
      redirect_to sign_in and return if cookie_validate["code"] != 20000 && !current_manager && params[:action] != 'home'
    end
    current_manager
  end

  def set_cookie(ticket, remaining_expires_time)
    domain = (request.domain == "localhost" ? request.domain : ".#{request.domain}")
    cookies[:st] = {value: ticket, expires: Time.at(Time.now.to_i + remaining_expires_time), domain: domain}
  end

  private

  def currency
    "#{params[:ask]}#{params[:bid]}".to_sym
  end

  def redirect_back_or_settings_page
    if cookies[:redirect_to].present?
      redirect_to URI.parse(cookies[:redirect_to]).path
      cookies[:redirect_to] = nil
    else
      redirect_to settings_path
    end
  end

  def current_manager
    @current_manager ||= Manager.where('id = ?', $datakeeper_redis_url.get(cookies[:st]).to_i).first
  end

  def check_email_nil
    redirect_to new_authentications_email_path if current_manager && current_manager.email.nil?
  end
end
