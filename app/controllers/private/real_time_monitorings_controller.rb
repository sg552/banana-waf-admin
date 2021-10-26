module Private
  class RealTimeMonitoringsController < ApplicationController #自动化运维监控
    before_action :set_real_time_monitoring, only: [:show, :edit, :update, :destroy]
    before_action :current_login
    # skip_before_action :authenticate_manager!, only: [
    #   :local_running_progress
    # ]
    include ApplicationHelper

    def local_running_progress #监测本地运行进程脚本
      progress_name = params[:progress_name]
      progress = ProgressMonitor.find_by_progress_name progress_name
      text = status_text(progress)
      if text.include?'脚本暂停'
        render json: {
          result: 'script stop'
        }, status: 500
      elsif text.include?'不正常'
        render json: {
          result: 'script error'
        }, status: 500
      else
        render json: {
          result: 'script normal'
        }
      end

    end

    def index #列表
      @real_time_monitorings = RealTimeMonitoring.all
    end

    def show #详情
    end

    def new #新增
      @real_time_monitoring = RealTimeMonitoring.new
    end

    def edit #编辑
    end

    def create #创建
      @real_time_monitoring = RealTimeMonitoring.new(real_time_monitoring_params)

      if @real_time_monitoring.save
        redirect_to real_time_monitorings_path, notice: 'Real time monitoring was successfully created.'
      else
        render :new
      end
    end

    def update #更新
      if @real_time_monitoring.update(real_time_monitoring_params)
        redirect_to real_time_monitorings_path, notice: 'Real time monitoring was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @real_time_monitoring.destroy
      redirect_to real_time_monitorings_url, notice: 'Real time monitoring was successfully destroyed.'
    end

    private
      def set_real_time_monitoring
        @real_time_monitoring = RealTimeMonitoring.find(params[:id])
      end

      def real_time_monitoring_params
        params.require(:real_time_monitoring).permit(:name, :last_checked_at, :monitoring_type, :last_error_send_sms_at, :last_error_send_sms_times, :last_error_call_at, :last_error_call_times, :status, :remark, :request_url, :request_interval)
      end
  end
end
