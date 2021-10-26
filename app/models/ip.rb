class Ip < ApplicationRecord
  # has_many :user_behaviers
  has_many :ip_for_members
  def update_friendly
    member_ids = IpForMember.where(ip_id: self.id).pluck(:member_id)

    real_name_member_count = Member.where(id: member_ids).where("real_name is not null and real_name != ?", "").count

    self.update!(friendly: (real_name_member_count.to_f / count).floor(2)) if count != 0
  end

  def safety_degree(download = nil)
    if download
      return '安全' if friendly >= 0.7
      return '普通' if (friendly < 0.7 && friendly >= 0.4) || count == 0
      return '危险' if friendly < 0.4
    else
      return "<span style='color: #1ab394'>安全</span>".html_safe if friendly >= 0.7
      return "<span style='color: #4395ff'>普通</span>".html_safe if (friendly < 0.7 && friendly >= 0.4) || count == 0
      return "<span style='color: red'>危险</span>".html_safe if friendly < 0.4
    end
  end

  def all_member_real_name
    ip_for_members = self.ip_for_members

    real_name_html = []
    not_real_name_html = []

    ip_for_members.each do |ip_for_member|
      member = ip_for_member.member
      if member.real_name.present?
        real_name_html << [member.id, member.real_name]
      else
        not_real_name_html << [member.id, member.mobile.present? ?  member.mobile : member.email]
      end
    end
    
    return {real_name_html: real_name_html, not_real_name_html: not_real_name_html}
  end
end