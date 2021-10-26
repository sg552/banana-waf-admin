module Private
  class WhiteIpsController < BaseController #白名单
    before_action :current_login
    before_action :set_white_ip, only: [ :destroy]

    def index #列表
      @white_ips = WhiteIp.all
      @white_ips = @white_ips.where(ip: params[:ip]) if params[:ip].present?
      @count = @white_ips.select(:ip).distinct.count(:id)
      @white_ips = @white_ips
        .order("created_at desc")
        .page(params[:page])
        .per(100)
    end

    def download_csv
      require 'csv'
      @white_ips = WhiteIp.all
      @white_ips = @white_ips.where(ip: params[:ip]) if params[:ip].present?
      headers = %w(ID IP 备注 时间)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @white_ips.each do |white_ip|
          csv << [
            white_ip.id,
            white_ip.ip,
            white_ip.remark,
            white_ip.created_at.strftime('%Y-%m-%d %H:%M:%S')
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_用户白名单.csv"
    end

    def new #新建
      @white_ip = WhiteIp.new
    end

    def create #创建
      @white_ip = WhiteIp.new(white_ip_params)
      @white_ip.save!
      redirect_to white_ips_path, notice: 'successfully created.'
    end

    def destroy
      @white_ip.destroy
      redirect_to white_ips_path, notice: 'successfully destroyed.'
    end

    private
    def set_white_ip
      @white_ip = WhiteIp.find(params[:id])
    end

    def white_ip_params
      $logger.info params
      params.require(:white_ip).permit(:ip, :remark)
    end
  end

end
