module Private::MemberHelper

  def member_detail(member)
    if member.present?
      detail = "ID: #{member.try(:id)}<br>"
      if member.try(:real_name).present?
        detail += "姓名: #{member.try(:real_name)}<br>\
                 手机: #{member.try(:mobile)}<br>\
                 邮箱: #{member.try(:email)}"
      else
        detail += '未实名'
      end
    else
      detail = '未登录'
    end
    detail.html_safe
  end
end
