#require 'rotp'
class ManagersController < ApplicationController #后台管理员
  before_action :current_login
  before_action :set_manager, only: [:edit_password, :update_password,
    :edit_google_otp, :update_google_otp, :edit_information, :update_information, :update_manager_role, :update_able_login]

  def index #列表
    @managers = Manager.all.page(params[:page]).per(500)
  end

  def show
  end

  def new #新增
    @manager = Manager.new
  end

  def edit #编辑
  end

  def edit_permissions
  end

  def create #创建
    @manager = Manager.new(manager_params)

    @manager.save!
    redirect_to managers_path, notice: '操作成功'
  end

  def update #更新
    @manager.update!(manager_params)
    redirect_to managers_path, notice: '操作成功'
  end

  def destroy
    @manager.destroy
    redirect_to managers_url, notice: '操作成功'
  end

  def edit_password
  end

  def update_password
    @manager.password = params[:new_password]
    @manager.save!
    redirect_back fallback_location: root_path, notice: '操作成功'
  end

  def edit_google_otp
    if current_manager.opt_secret.blank?
      ActiveRecord::Base.connected_to(role: :writing) do
        ActiveRecord::Base.connection_handler.while_preventing_writes(false) do
          current_manager.update_attributes! opt_secret: ROTP::Base32.random_base32
        end
      end
    end
    @otp_url = "otpauth://totp/#{current_manager.email}?secret=#{current_manager.opt_secret}&issuer=#{ENV['GOOGLE_OTP_ISSUER']}"
  end

  def update_google_otp

    if @manager.get_otp_code == params[:otp_code]
      @manager.is_otp_binded = true
      @manager.save!
      redirect_back fallback_location: root_path, notice: '操作成功'
    else
      redirect_back fallback_location: root_path, notice: '操作失败'
    end
  end

  def edit_information

  end

  def update_information

    query = {nick_name: params[:manager][:nick_name]}
    query.merge!({portrait_icon: Manager.upload_file(@manager.id, params[:manager][:portrait_icon])}) if params[:manager][:portrait_icon].present?
    @manager.update(query)
    redirect_back fallback_location: root_path, notice: '操作成功'
  end

  def update_manager_role #更新管理员角色
    @manager.update!(role_id: params[:role_id])
    redirect_back fallback_location: root_path, notice: '操作成功'
  end

  def update_able_login #设置账号是否可以登录
    @manager.update!(is_able_to_login: params[:is_able_to_login])
    @manager.able_login if params[:is_able_to_login].to_s == 'false'
    redirect_back fallback_location: root_path, notice: '操作成功'
  end

  private
    def set_manager
      @manager = Manager.find(params[:id])
    end

    def manager_params
      params.require(:manager).permit(:email, :password, :phone, :is_able_to_login)
    end

end
