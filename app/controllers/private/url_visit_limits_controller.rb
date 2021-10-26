module Private
  class UrlVisitLimitsController < BaseController #用户资产
    before_action :set_url_visit_limit, only: [:edit, :destroy, :update_data]
    before_action :url_visit_limits, only: [:index, :download_csv]
    before_action :current_login
    def index #资产
      @url_visit_limits_count = @url_visit_limits.count
      @url_visit_limits = @url_visit_limits
        .order('id desc')
        .page(params[:page])
        .per(100)
    end

    def download_csv
      require 'csv'
      headers = %w(ID 行为名称 URL 单位时间内访问最大次数 单位时间(秒))
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @url_visit_limits.each do |url_visit_limit|
          csv << [
            url_visit_limit.id,
            url_visit_limit.behavier.try(:behavier_name),
            url_visit_limit.behavier.try(:url),
            url_visit_limit.maximum_times,
            url_visit_limit.duration
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_单位时间访问限制.csv"
    end

    def create
      UrlVisitLimit.create!(
        behavier_id: params[:behavier_id],
        maximum_times: params[:maximum_times],
        duration: params[:duration],
        )
      redirect_to url_visit_limits_path
    end

    def edit
      render json: @url_visit_limit
    end

    def update_data
      @url_visit_limit.update!(
        behavier_id: params[:behavier_id],
        maximum_times: params[:maximum_times],
        duration: params[:duration],
        )
      redirect_to url_visit_limits_path
    end

    def destroy
      @url_visit_limit.destroy
      redirect_to url_visit_limits_path, notice: '删除成功'
    end

    private

      def url_visit_limits
        @url_visit_limits = UrlVisitLimit.includes(:behavier)
        @url_visit_limits= @url_visit_limits.where('behavier_id = ?', params[:behavier_id]) if params[:behavier_id].present?
        @url_visit_limits = @url_visit_limits.where('maximum_times = ?', params[:maximum_times]) if params[:maximum_times].present?
        @url_visit_limits = @url_visit_limits.where('duration= ?', params[:duration]) if params[:duration].present?
      end

      def set_url_visit_limit
        @url_visit_limit = UrlVisitLimit.find(params[:id])
      end


  end
end
