module ApplicationHelper

  def get_fav_from_system_variables
     fav = SystemVariable.find_by_name 'favicon'
     value = ""
     if fav.present?
        value = fav.value
     end
     value
  end

  def get_footer_left_text
     left_text = SystemVariable.find_by_name 'footer_left_text'
     text = ""
     if left_text.present?
       text = left_text.value
     end
     text
  end

  def get_footer_right_text
     left_text = SystemVariable.find_by_name 'footer_right_text'
     text = ""
     if left_text.present?
       text = left_text.value
     end
     text
  end

  def user_behavier_info(behavier)
    "ID： #{behavier.try(:id)}<br/>\
     行为名称： #{behavier.try(:behavier_name)}<br/>\
     URL： #{behavier.try(:url)}<br/>".html_safe
  end

  def get_menu_cookie
    selected_menu = cookies[:selected_menu]
    first_menu = cookies[:selected_menu].split('_')[0] rescue nil
    [first_menu, selected_menu]
  end

  def short_format options
    return '' if options[:content].blank?
    content = options[:content]
    digit = options[:digit] || 5
    return "#{content[0, digit]}...#{content[(0 - digit).. -1]}"
  end

  def power
    role_id = Manager.find(current_manager.id).role_id
    role = Role.find(role_id).name
  end

  def status_text progress
    begin
      if Time.now - progress.checked_at > 10.minutes
        return '<span style="width: 100px;color:yellow;">脚本暂停</span>'
      elsif progress.status == '不正常'
        return '<span style="width: 100px;color:red;">已停止</span>'
      elsif progress.status == '正常'
        return '<span style="width: 100px;color:lightgreen;">运行中</span>'
      else
        return ''
      end
    rescue
      return '刚启用'
    end
  end

  def shorten_string(long_string, startLength=5)
    begin
      length = long_string.length
      "#{long_string[0,startLength]}....#{long_string[length - 4,length]}"
    rescue Exception => e
      return ''
    end
  end
  require 'base64'
  def generate_qr_code string
    qr_code = RQRCode::QRCode.new string
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 180,
      border_modules: 0,
      module_px_size: 0,
      file: nil # path to write
    ).to_s
    Base64.encode64 png
    return "data:image/png;base64,#{Base64.encode64(png)}"
  end
end
