module Private
  class DevicesController < BaseController
    before_action :current_login
    before_action :set_device, only: [:edit, :update]
    before_action :search_devices, only: [:index, :download_csv]

    def index #列表
      @devices = @devices.order("id desc").page(params[:page]).per(100)
    end

    def download_csv
      require 'csv'
      headers = %w(ID User-agent 类型 品牌 名称 操作系统名称 供应商 设备名称 设备品牌 浏览器名称 浏览器版本)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @devices.each do |device|
          device.os_url.present? 
          csv << [
            device.id,
            device.user_agent,
            device.ua_type,
            device.brand,
            device.brand_name,
            device.os_name,
            device.os_family_vendor,
            device.device_name,
            device.device_brand,
            device.browser_name,
            device.browser_version
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_设备.csv"
    end

    def edit #编辑
    end

    def update
      if @device.update(device_params)
        redirect_to devices_path, notice: '更新成功'
      else
        render :edit
      end
    end

    private

    def search_devices
      @devices = Device.all
      @devices = @devices.where(user_agent: params[:user_agent]) if params[:user_agent].present?
      @devices = @devices.where("length(user_agent) >= ?", params[:length_from].to_i) if params[:length_from].present?
      @devices = @devices.where("length(user_agent) <= ?", params[:length_to].to_i) if params[:length_to].present?
      @devices = @devices.where(id: params[:id]) if params[:id].present?
      @devices = @devices.where(ua_type: params[:ua_type]) if params[:ua_type].present?
      @devices = @devices.where(device_type: params[:device_type]) if params[:device_type].present?
    end

    def set_device
      @device = Device.find params[:id]
    end

    def device_params
      params.require(:device).permit(:comment)
    end

  end

end
