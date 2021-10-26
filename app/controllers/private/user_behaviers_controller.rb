module Private
  class UserBehaviersController < BaseController
    before_action :current_login
    before_action :user_behavies, only: [:index, :download_csv]
    before_action :search_ip_statistical_analysis, only: [:ip_statistical_analysis, :download_csv_ip_statistical_analysis]
    before_action :get_user_behavier_access_analysis, only: [
      :user_behavier_access_analysis,
      :download_user_behavier_access_analysis
    ]
    def index #列表
      # @count = @behaviers.count
      @behaviers = @behaviers
        .order("time desc")
        .page(params[:page]).per(200).without_count
    end

    def download_csv
      require 'csv'
      headers = %w(ID IP 归属地 友善度 用户id 用户姓名 用户手机 用户邮箱 设备信息 访问时间 请求方式 访问域名 用户行为 url params)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @behaviers.each do |user_behavier|
          ip = user_behavier.ip
          csv << [
            user_behavier.id,
            ip.try(:ip_address),
            ip.try(:attribution),
            "#{ip.try(:friendly).to_d*100}%",
            user_behavier.member.try(:id),
            user_behavier.member.try(:real_name),
            user_behavier.member.try(:mobile),
            user_behavier.member.try(:email),
            user_behavier.device.try(:ua_type),
            user_behavier.device.try(:brand),
            user_behavier.device.try(:brand_name),
            user_behavier.time.strftime('%Y-%m-%d %H:%M:%S'),
            user_behavier.http_method,
            user_behavier.host.try(:name),
            user_behavier.behavier.behavier_name,
            user_behavier.uri,
            user_behavier.params_text
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_用户行为记录.csv"
    end

    def ip_statistical_analysis # IP统计分析
      @ip_statistical_analysis_count = @ip_statistical_analysis.count
      @ip_statistical_analysis = @ip_statistical_analysis.page(params[:page]).per(200).without_count
    end

    def download_csv_ip_statistical_analysis
      require 'csv'
      headers = %w(IP 归属地 人数 实名百分比 实名用户 未实名用户 安全分析)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @ip_statistical_analysis.each do |ip_statistical_analysi|
          all_member_real_name = ip_statistical_analysi.all_member_real_name
          real_name_html = all_member_real_name[:real_name_html]
          not_real_name_html = all_member_real_name[:not_real_name_html]
          csv << [
            ip_statistical_analysi.ip_address,
            ip_statistical_analysi.attribution,
            ip_statistical_analysi.count,
            "#{ip_statistical_analysi.friendly.to_d * 100.to_d}%",
            real_name_html.to_h.values.join(','),
            not_real_name_html.to_h.values.join(','),
            ip_statistical_analysi.safety_degree(true)
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_用户共用IP分析.csv"
    end

    def ip_statistical_analysis_user_show
      @shared_ip_users = Ip.where(ip_address: params[:ip]).joins(:ip_for_members)
      @shared_ip_users = @shared_ip_users.first.ip_for_members.page(params[:page]).per(50).without_count
    end

    def user_behavier_access_analysis # 行为访问频率分析
    end

    def download_user_behavier_access_analysis
      require 'csv'
      headers = %w(行为 总访问次数)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @user_user_behavier_access_analysis.each do |user_user_behavier_access_analysi|
          csv << [
            user_user_behavier_access_analysi.behavier.try(:behavier_name),
            user_user_behavier_access_analysi.count
          ]
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
                :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_行为访问频率统计分析.csv"
    end

    def user_behavier_access_analysis_show
      @behavier = Behavier.find(params[:behavier_id])
      @user_user_behavier_access_analysis_show = UserBehavier.where(behavier_id: params[:behavier_id]).group(:member_id)
        .select('member_id, sum(visit_count) as count').order("count desc")
    end

    def member_behavies
    end

    private

      def user_behavies
        # debug 模式。。。只看ip
        if false
          Rails.logger.info "==== in debug mode, find id: #{params[:ip]}"
          ip = Ip.where("ip_address = ?", params[:ip]).first
          Rails.logger.info "==== in debug mode, ip: #{ip.inspect}"

          @behaviers = UserBehavier.where("ip_id =? ", ip.id) if ip.present?

        else
          @behaviers = UserBehavier.includes(:member, :host)
          @behaviers = @behaviers.where(ip: params[:ip]) if params[:ip].present?
          @behaviers = @behaviers.where(member_id: params[:member_id]) if params[:member_id].present?
          @behaviers = @behaviers.where(device_id: params[:device_id]) if params[:device_id].present?
          @behaviers = @behaviers.where(behavier_id: params[:behavier_id]) if params[:behavier_id].present?
          @behaviers = @behaviers.where(host_id: params[:host_id]) if params[:host_id].present?
          if params[:account].present?
            members = Member.where("mobile = ? or email = ?", params[:account], params[:account])
            if members.present?
              member = members.first
              @behaviers = @behaviers.where(member_id: member.id)
            end
          end
        end
        @behaviers = @behaviers.where('time>= ?', DateTime.parse(params[:from]).beginning_of_day) if params[:from].present?
        @behaviers = @behaviers.where('time<= ?', DateTime.parse(params[:to]).end_of_day) if params[:to].present?
      end

      def search_ip_statistical_analysis
        @ip_statistical_analysis = Ip.includes(:ip_for_members)
        @ip_statistical_analysis = @ip_statistical_analysis.where(ip_address: params[:ip]) if params[:ip].present?

        # 搜索安全、普通、危险
        if params[:state].present?
          if params[:state] == 'security'
            @ip_statistical_analysis = @ip_statistical_analysis.where("friendly >= ?", 0.7)
          elsif params[:state] == 'ordinary'
            @ip_statistical_analysis = @ip_statistical_analysis.where("friendly < ? and friendly >= ? or count = ?", 0.7, 0.4, 0)
          else
            @ip_statistical_analysis = @ip_statistical_analysis.where("friendly < ? and count != ?", 0.4, 0)
          end
        end

        @ip_statistical_analysis = @ip_statistical_analysis
          .joins(:ip_for_members).where("ip_for_members.member_id = ? ", params[:member_id]) if params[:member_id].present?

        @ip_statistical_analysis = @ip_statistical_analysis.where("count >= ?", params[:user_count]) if params[:user_count].present?
        if params[:order] == "count_asc"
          @ip_statistical_analysis = @ip_statistical_analysis.order("count asc")
        elsif params[:order] == "count_desc"
          @ip_statistical_analysis = @ip_statistical_analysis.order("count desc")
        elsif params[:order] == "friendly_asc"
          @ip_statistical_analysis = @ip_statistical_analysis.order("friendly asc")
        else params[:order] == "count_asc"
          @ip_statistical_analysis = @ip_statistical_analysis.order("friendly desc")
        end
      end

      def get_user_behavier_access_analysis
        @user_user_behavier_access_analysis = UserBehavier.group(:behavier_id)
        .select('behavier_id, sum(visit_count) as count').order("count desc")
      end

  end
end
