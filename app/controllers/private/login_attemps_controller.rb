module Private # 系统监控
  class LoginAttempsController < BaseController # 系统监控 - 用户登录IP等情况
    before_action :current_login
    before_action :search_by_params, only: [:index, :download_csv]

    def index  #  用户错误的密码尝试列表
      @login_attemps = @login_attemps.page(params[:page]).per(200)
    end

    def download_csv #下载csv
      require 'csv'
      headers = %w(ID 用户ID 邮箱 手机号 姓名 身份证号码 地址 注册时间 尝试的密码 IP 发生时间 详细信息)
      file = CSV.generate do |csv|
        # 先放　header
        csv << headers
        # 再放 csv 的内容
        @login_attemps.each do |login_attemp|
          member = login_attemp.member

          # 隐藏一些信息
          if login_attemp.created_at < '2020-07-29'
            number = member.id_card_approval.try(:number).presence
            if number.present?
              number[6..11] = '*' * 6
            end
            address = member.id_card_approval.try(:address).presence
            if address.present?
              address[4..10] = '*' * 7
            end
            mobile = member.mobile
            if mobile.present?
              mobile[3..6] = '*' * 4
            end

            email = member.email
            if email.present?
              email[3..6] = '*' * 4
            end
            wrong_password = login_attemp.wrong_password
            if wrong_password.present?
              wrong_password[2..5] = '*' * 4
            end
            csv << [
              login_attemp.id,
              member.id,
              email,
              "#{mobile}\t",
              "#{member.id_card_approval.try(:name).presence rescue '-'} ",
              "#{number}\t",
              address,
              "#{member.created_at.strftime("%Y-%m-%d %H:%M:%S")}\t",
              wrong_password,
              login_attemp.ip,
              "#{login_attemp.created_at.strftime("%Y-%m-%d %H:%M:%S")}\t",
              login_attemp.comment
            ]
          else
          csv << [
            login_attemp.id,
            member.id,
                  member.try(:email).presence,
                  "#{member.try(:mobile).presence}\t",
                  member.id_card_approval.try(:name).presence,
                  "#{member.id_card_approval.try(:number).presence}\t",
                  member.id_card_approval.try(:address).presence,
                  "#{member.created_at.strftime("%Y-%m-%d %H:%M:%S")}\t",
                  login_attemp.wrong_password,
                  login_attemp.ip,
                  "#{login_attemp.created_at.strftime("%Y-%m-%d %H:%M:%S")}\t",
                  login_attemp.comment
          ]
          end
        end
      end
      send_data file.encode("gbk", "utf-8"), :type => 'text/csv; charset=gbk; header=present',
        :disposition => "attachment;filename=#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}_用户错误的密码尝试.csv"
    end

    def ip_login_error_count
      @ip_error_count = []
      LoginAttemp.all.group_by{|g| g.ip }.each do |ip, record_group|
        @ip_error_count << {ip: ip, count: record_group.count}
      end
      @ip_error_count = @ip_error_count.sort_by{ |hsh| hsh[:count] }.reverse
      @ip_error_count = Kaminari.paginate_array(@ip_error_count).page(params[:page]).per(200)
    end

    def device_login_error_count
      @device_error_count = []
      LoginAttemp.all.group_by{|g| g.user_agent }.each do |user_agent, record_group|
        @device_error_count << {user_agent: user_agent, count: record_group.count}
      end
      @device_error_count = @device_error_count.sort_by{ |hsh| hsh[:count] }.reverse
      @device_error_count = Kaminari.paginate_array(@device_error_count).page(params[:page]).per(200)
    end

    def member_login_error_count
      @member_error_count = []
      LoginAttemp.where(os_type: "admin").group_by{|g| g.member_id }.each do |member_id, record_group|
        @member_error_count << {member_id: member_id, os_type: 'admin', login_name: record_group.first.login, count: record_group.count}
      end
      LoginAttemp.where("os_type != ? and os_type != ''",'admin').group_by{|g| g.member_id }.each do |member_id, record_group|
        @member_error_count << {member_id: member_id, os_type: 'member', count: record_group.count}
      end
      @member_error_count = @member_error_count.sort_by{ |hsh| hsh[:count] }.reverse
      @member_error_count = Kaminari.paginate_array(@member_error_count).page(params[:page]).per(200)
    end

    def search_by_params
      @login_attemps = LoginAttemp
      @login_attemps = @login_attemps.where('member_id in (?)', params[:member_ids].split(',')) if params[:member_ids].present?
      @login_attemps = @login_attemps.where('created_at >= ?', params[:from]) if params[:from].present?
      @login_attemps = @login_attemps.where('created_at <= ?', params[:to]) if params[:to].present?
      if params[:os_type].present?
        if params[:os_type] === 'pc'
         @login_attemps = @login_attemps.where("os_type not in (?)",['ios','android'])
        else
         @login_attemps = @login_attemps.where('os_type = ?', params[:os_type])
        end
      end
      @login_attemps = @login_attemps.order('id desc')
    end
  end
end
