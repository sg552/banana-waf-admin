class MembersController < ApplicationController#用户
  before_action :current_login
  before_action :get_member, only: [:index]
  before_action :get_behaviers, only: [:index]

  def index #用户行为详情
    @ip_for_members = get_members_ip_list
    @behavier_user_agents = get_members_user_agents
    @count = @behaviers.count
    @user_behaviers = @behaviers.group(:behavier_id).select('behavier_id, sum(visit_count) as count').order("count desc")
  end

  def behavier_chart
  end

  private
  def get_member
    @member = Member.find_by_id params[:id]
  end

  def get_behaviers
    @behaviers = UserBehavier.where('member_id = ?', @member.id)
  end

  def get_members_ip_list
    @member.ip_for_members
  end

  def get_members_user_agents
    @behaviers.select(:user_agent).distinct
  end

end
