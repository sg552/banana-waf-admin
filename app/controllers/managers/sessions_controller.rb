# frozen_string_literal: true
class Managers::SessionsController < DeviseController
  prepend_before_action :require_no_authentication, only: [:new, :create]
  before_action :current_login
  # prepend_before_action(only: [:create, :destroy]) { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
    redirect_to root_path
    # self.resource = resource_class.new(sign_in_params)
    # render layout: 'empty'
  end

  # POST /resource/sign_in
  def create
    manager = Manager.where('email = ?', params[:manager][:email]).first
    if manager.blank?
      redirect_to :back, alert: '用户名不存在。请立刻联系管理员。多次尝试失败会上报风控系统' and return
    end
    
    redirect_to :back, alert: '您登陆错误次数太多，账号已被禁用，请联系系统管理员' and return if manager.max_login_attemps_error?
    if manager.is_otp_binded && manager.get_otp_code != params[:manager][:otp_code]
     redirect_to '/managers/sign_in', alert: '您的google 验证码不正确' and return
    end

    if manager.blank? || !manager.valid_password?(params[:manager][:password])
      manager.record_login_error_msg({login_name: params[:manager][:email], wrong_password: params[:manager][:password], msg: '邮箱与密码不匹配', ip:request.remote_ip})
      redirect_to :back, alert: '邮箱与密码不匹配' and return
    end

    if manager.valid_password? params[:manager][:password]
      sign_in manager
      redirect_to after_sign_in_path_for(manager), alert: "登录成功"
    else
      redirect_to :back, alert: '邮箱与密码不匹配'
    end
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out = Sso.sign_out(cookies[:st])
    redirect_to :back and return if sign_out["code"] != 20000
    $datakeeper_redis_url.del(cookies[:st])
    domain = (request.domain == "localhost" ? request.domain : ".#{request.domain}")
    cookies.delete(:st,:domain => domain)
    redirect_to root_path
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { methods: methods, only: [:password] }
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  def translation_scope
    'devise.sessions'
  end

  private

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    if all_signed_out?
      set_flash_message! :notice, :already_signed_out

      respond_to_on_destroy
    end
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end
