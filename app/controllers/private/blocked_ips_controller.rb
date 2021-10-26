module Private
  class BlockedIpsController < BaseController # 封禁的所有IP
    before_action :current_login
    before_action :set_blocked_ip, only: [:show, :edit, :update, :destroy, :unblocked, :blocked]
    before_action :search_blocked_ips, only: [:index, :download_csv]

    def index #列表
      @count = @blocked_ips.select(:ip).distinct.count(:id)
      @blocked_ips = @blocked_ips
        .order("created_at desc")
        .page(params[:page]).per(200).without_count
    end

    def download_csv
      require 'csv'
      headers = %w(ID IP 封禁人 封禁的时间 封禁理由 封禁信息 解封人 解封时间 解封理由 被封禁)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        blocked_ips = @blocked_ips.includes(:blocked_manager)
        blocked_ips.each do |blocked_ip|
          csv << [
            blocked_ip.id,
            blocked_ip.ip,
            blocked_ip.blocked_manager.try(:email),
            blocked_ip.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            blocked_ip.blocked_reason,
            blocked_ip.get_comment.html_safe,
            blocked_ip.unblocked_manager.try(:email),
            blocked_ip.unblocked_at.try('strftime','%Y-%m-%d %H:%M:%S'),
            blocked_ip.unblocked_reason,
            blocked_ip.is_blocked? ? "是":"否"
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_被封IP信息.csv"
    end

    def show
    end

    def new #新建
      @blocked_ip = BlockedIp.new
    end

    def edit
    end

    def create #创建
      @blocked_ip = BlockedIp.new(blocked_ip_params)
      begin
        @blocked_ip.save!
      rescue Exception=> e
      end
      redirect_to blocked_ips_path, notice: 'successfully created.'
    end

    def unblocked #解禁IP操作
      @blocked_ip.update!(
        is_blocked: false,
        unblocked_at: Time.new,
        unblocked_reason: params[:unblocked_reason],
        unblocked_by: current_manager.id
        )
      redirect_to blocked_ips_path, notice: '解禁成功'
    end

    def blocked #封禁IP操作
      @blocked_ip.update!(
        is_blocked: true,
        blocked_reason: params[:unblocked_reason],
        blocked_by: current_manager.id
      )
      redirect_to blocked_ips_path, notice: '重新封禁成功'
    end

    def update
      if @blocked_ip.update(blocked_ip_params)
        redirect_to blocked_ips_path, notice: 'App version was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @blocked_ip.destroy
      redirect_to blocked_ips_path, notice: 'App version was successfully destroyed.'
    end

    private
      def set_blocked_ip
        @blocked_ip = BlockedIp.find(params[:id])
      end

      def search_blocked_ips
        @blocked_ips = BlockedIp.all
        @blocked_ips = @blocked_ips.where(ip: params[:ip]) if params[:ip].present?
        @blocked_ips = @blocked_ips.where('created_at >= ?', DateTime.parse(params[:from]).beginning_of_day) if params[:from].present?
        @blocked_ips = @blocked_ips.where('created_at <= ?', DateTime.parse(params[:to]).end_of_day) if params[:to].present?
        @blocked_ips = @blocked_ips.joins(:blocked_manager).where("managers.email = ?", params[:blocked_by]) if params[:blocked_by].present?
        @blocked_ips = @blocked_ips.where(blocked_reason: params[:blocked_reason]) if params[:blocked_reason].present?
        if params[:unblocked_by].present?
          ids = Manager.where(email: params[:unblocked_by]).pluck(:id)
          @blocked_ips = @blocked_ips.joins(:unblocked_manager).where(unblocked_by: ids)
        end
        @blocked_ips = @blocked_ips.where(is_blocked: params[:is_blocked]) if params[:is_blocked].present?
      end

      def blocked_ip_params
        params.require(:blocked_ip).permit(:ip, :blocked_by, :blocked_reason, :unblocked_by, :unblocked_reason, :comment, :address, :is_blocked, :unblocked_at)
      end
  end
end
