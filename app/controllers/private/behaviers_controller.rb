module Private
  class BehaviersController < BaseController #用户行为
    before_action :current_login
    before_action :set_behavier, only: [:edit, :destroy, :update_data]
    before_action :search_behaviers, only: [:index, :download_csv]
    def index 
      @behaviers_count = @behaviers.count
      @behaviers = @behaviers
        .order('id desc')
        .page(params[:page])
        .per(100)
    end

    def download_csv
      require 'csv'
      headers = %w(ID 用户行为名称 url 请求方式)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @behaviers.each do |behavier|
          csv << [
            behavier.id,
            behavier.behavier_name,
            behavier.url,
            behavier.http_method
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_用户行为设置.csv"
    end

    def create
      Behavier.create!(
        url: params[:url].strip,
        behavier_name: params[:behavier_name],
        http_method: params[:http_method]
        )
      redirect_to behaviers_path
    end

    def edit
      render json: @behavier
    end

    def update_data
      @behavier.update!(
        url: params[:url].strip,
        behavier_name: params[:behavier_name],
        http_method: params[:http_method]
        )
      redirect_to behaviers_path
    end

    def destroy
      @behavier.destroy
      redirect_to behaviers_path, notice: '删除成功'
    end

    private

      def search_behaviers
        @behaviers = Behavier.all
        @behaviers = @behaviers.where('url = ?', params[:url]) if params[:url].present?
        @behaviers = @behaviers.where('behavier_name = ?', params[:behavier_name]) if params[:behavier_name].present?
        @behaviers = @behaviers.where('http_method= ?', params[:http_method]) if params[:http_method].present?
      end

      def set_behavier
        @behavier = Behavier.find(params[:id])
      end
  end
end
