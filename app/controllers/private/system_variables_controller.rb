module Private
  class SystemVariablesController < BaseController #系统常量
    before_action :current_login
    before_action :get_by_id, only: [:edit, :update]

    def index #列表
      @system_variables = SystemVariable
      if params[:query].present?
        @system_variables = @system_variables
                              .where("name like ? or comment like ?",
                                     "%#{params[:query]}%", "%#{params[:query]}%")
      end
      @system_variables = @system_variables
        .order('updated_at desc')
        .page(params[:page])
        .per(100)
    end

    def new #新建
      @system_variable = SystemVariable.new
    end

    def create #创建
      @system_variable = SystemVariable.new system_variable_params
      if @system_variable.save
        redirect_to system_variables_path, notice: '操作成功'
      else
        redirect_to :back, error: '操作失败'
        Rails.logger.error @system_variable.errors.messages
      end
    end

    def edit #编辑
    end

    def update #更新
      if @system_variable.update(system_variable_params )
        redirect_to :back, notice: '操作成功'
      else
        redirect_to :back, error: '操作失败'
        Rails.logger.error @system_variable.errors.messages
      end
    end

    def setting_default_locale #设置默认语言
      @default_locale = SystemVariable.where(name: 'set_default_locale').first
    end

    def create_and_new_locale #创建默认语言
      @default_locale = SystemVariable.find_or_create_by(name: 'set_default_locale' )
      @default_locale.update(value: params[:value])
      redirect_to setting_default_locale_system_variables_path, notice: '操作成功'
    end

    def setting_alarm_receiving_telephone #设置报警接收电话
      @alarm_receiving_telephones = SystemVariable.where(name: 'alarm_receiving_telephone').first
    end

    def create_alarm_receiving_telephone #创建报警接收电话
      phones = params[:value].join(',').gsub('，',',')
      @alarm_receiving_telephone = SystemVariable.find_or_create_by(name: 'alarm_receiving_telephone' )
      @alarm_receiving_telephone.update(value: phones)
      redirect_to setting_alarm_receiving_telephone_system_variables_path, notice: '操作成功'
    end

    def setting_draw_message_receive_phone #设置提币接收电话
      @draw_message_receive_phones = SystemVariable.where(name: 'draw_message_receive_phone').first
    end

    def create_draw_message_receive_phone #创建提币接收电话
      phones = params[:value].join(',').gsub('，',',')
      @draw_message_receive_phone = SystemVariable.find_or_create_by(name: 'draw_message_receive_phone' )
      @draw_message_receive_phone.update(value: phones)
      redirect_to setting_draw_message_receive_phone_system_variables_path, notice: '操作成功'
    end

    def setting_transaction_pairs #设置默认交易对（跳转链接参数）
      @transaction_pairs = SystemVariable.where(name: 'transaction_pairs').first
    end

    def create_transaction_pairs #创建默认交易对
      @transaction_pairs = SystemVariable.find_or_create_by(name: 'transaction_pairs' )
      @transaction_pairs.update(value: params[:value])
      redirect_to setting_transaction_pairs_system_variables_path, notice: '操作成功'
    end

    def add_robot #添加机器人ID
      @robots = SystemVariable.where(name: "robot").order("id desc")
    end

    def create_robot #创建机器人ID数据
      params[:value].join(',').gsub('，',',').split(',').each do |robot_id|
        @robots = SystemVariable.find_or_create_by(name: 'robot', value: robot_id)
      end
      redirect_to add_robot_system_variables_path, notice: '操作成功'
    end

    def delete_robot #删除机器人ID
      SystemVariable.find(params[:id]).delete
      redirect_to add_robot_system_variables_path, notice: '删除成功'
    end

    def setting_member_login_attemps #编辑member允许最大登录次数
      @max_failed_login_attemps = SystemVariable.find_by_name('max_failed_login_attemps')
      @assets_password_max_failed = SystemVariable.find_by_name('assets_password_max_failed')
    end

    def create_member_login_attemps #更新member允许最大登录次数
      login_attemps = SystemVariable.find_or_create_by(name: 'max_failed_login_attemps')
      assets_password_max_failed = SystemVariable.find_or_create_by(name: 'assets_password_max_failed')
      login_attemps.value = params[:max_failed][0]
      assets_password_max_failed.value = params[:assets_password_max_failed][0]
      login_attemps.save
      assets_password_max_failed.save
      redirect_to setting_member_login_attemps_system_variables_path, notice: '操作成功'
    end

    def setting_manager_login_attemps #编辑manager允许最大登录次数
      SystemVariable.find_or_create_by(name: 'max_failed_manager_login_attemps')
      @max_failed_manager_login_attemps = SystemVariable.find_by_name('max_failed_manager_login_attemps')
    end

    def creat_manager_login_attemps #更新manager允许最大登录次数
      max_failed_manager_login_attemps = SystemVariable.find_by_name('max_failed_manager_login_attemps')
      max_failed_manager_login_attemps.value = params[:max_failed_manager_login_attemps][0]
      max_failed_manager_login_attemps.save
      redirect_to setting_manager_login_attemps_system_variables_path, notice: '操作成功'
    end

    def k_lines_preference #k线编辑器配置项
      @preference = SystemVariable.where("comment like 'k线编辑器配置项%'").page(params[:page]).per(100)
    end

    def pair_tab_setting #首页交易对便签显示设置
      # 避免N+1查询(options_from_collection_for_select)
      @pairs_options = Market.where(visible: true)
      @currency_options = Currency.where(visible: true)

      @pairs = SystemVariable.where(name: "pair_tab_setting_pairs").first
      @main_tab = SystemVariable.where(name: "pair_tab_setting_main_tab").first
      #@innovation_tab = SystemVariable.where(name: "pair_tab_setting_innovation_tab")
      if @pairs.blank? && @main_tab.blank?
        SystemVariable.create!(
          name: "pair_tab_setting_pairs",
          value: "btcusdt,ethusdt,cgusdt,ethbtc,cgbtc",
          comment: "五个交易对价格变动显示"
        )
        SystemVariable.create!(
          name: "pair_tab_setting_main_tab",
          value: "usdt,btc,eth",
          comment: "行情中心主区的三个便签页"
        )
        @pairs = SystemVariable.where(name: "pair_tab_setting_pairs").first
        @main_tab = SystemVariable.where(name: "pair_tab_setting_main_tab").first
      end
      @markets = @pairs.value.split ','
      @main_tabs = @main_tab.value.split ','
    end

    def save_pair_tab_setting #保存首页交易对便签显示设置
      markets = []
      5.times { |index| markets << params["pair_#{index}".to_sym] }
      pairs = SystemVariable.where(name: "pair_tab_setting_pairs").first
      main_tab = SystemVariable.where(name: "pair_tab_setting_main_tab").first

      logger.warn "== markets=#{markets}"
      logger.warn "== paris=#{[params[:main_0],params[:main_1],params[:main_2]].join(",")}"

      pairs.update! value: markets.join(",")
      main_tab.update! value: [params[:main_0],params[:main_1],params[:main_2]].join(",")
      redirect_to :back, notice: '保存成功'
    end

    def about_us_url #关于我们
      @about_us_urls = SystemVariable.where(name: 'about_us_url')
        .order('updated_at desc')
        .page(params[:page])
        .per(100)
    end

    def contact_us_url #联系我们
      @contact_us_urls = SystemVariable.where(name: 'contact_us_url')
        .order('updated_at desc')
        .page(params[:page])
        .per(100)
    end

    def app_download_link #APP及二维码下载地址
      @ios_app_down_link = SystemVariable.find_by_name("ios_app_down_link")
      @ios_app_down_qr_code_img_link = SystemVariable.find_by_name("ios_app_down_qr_code_img_link")
      @android_app_down_link = SystemVariable.find_by_name("android_app_down_link")
      @android_app_down_qr_code_img_link = SystemVariable.find_by_name("android_app_down_qr_code_img_link")
    end

    def create_app_download_link #创建APP及二维码下载地址
      SystemVariable.find_by_name("ios_app_down_link").update!(value: params[:ios_app_down_link])
      SystemVariable.find_by_name("ios_app_down_qr_code_img_link").update!(value: params[:ios_app_down_qr_code_img_link])
      SystemVariable.find_by_name("android_app_down_link").update!(value: params[:android_app_down_link])
      SystemVariable.find_by_name("android_app_down_qr_code_img_link").update!(value: params[:android_app_down_qr_code_img_link])
      redirect_to :back, notice: '保存成功'
    end

    def leverage_interest #杠杆借贷利息设置
      @leverage_interest = SystemVariable.find_by_name("leverage_interest")
    end

    def create_leverage_interest  #保存杠杆借贷利息
      @leverage_interest = SystemVariable.find_by_name("leverage_interest")
      if @leverage_interest
        @leverage_interest = @leverage_interest.update(value: params[:value].first)
      else
        @leverage_interest = SystemVariable.create(name: "leverage_interest", value: params[:value].first, comment: "杠杆借贷利息")
      end
      redirect_to :back, notice: '杠杆借贷利息设置成功'
    end

    def sms_balance #短信余额详情列表
      body = { :apikey => '8624605179da4345750c02c4c2023fa6' }
      url = 'https://sms.yunpian.com/v2/user/get.json'
      response = HTTParty.post(url, :body => body )
      @result = response.parsed_response
    end


    private
    def get_by_id
      @system_variable = SystemVariable.find_by_id params[:id]
    end

    def system_variable_params
      params.require(:system_variable).permit(:name, :value, :comment)
    end
  end
end
