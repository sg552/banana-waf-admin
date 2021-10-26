class RolesController < ApplicationController #角色
  before_action :set_role, only: [:show, :edit, :update, :destroy, :setting_role_permission, :update_role_permission]

  def index #列表
    @roles = Role.all.page(params[:page]).per(500)
  end

  def show #详情
  end

  def new #新建
    @role = Role.new
  end

  def edit #编辑
  end

  def create #创建
    @role = Role.new(role_params)

    @role.save!
    redirect_to roles_path, notice: '操作成功'
  end

  def update #更新
    @role.update!(role_params)
    redirect_to roles_path, notice: '操作成功'
  end

  def destroy #删除
    @role.destroy
    redirect_to roles_url, notice: '操作成功'
  end

  def setting_role_permission #角色权限设置
    @parent_permissions = RolePermission.parent_permission.order("id asc")
  end

  def update_role_permission #角色权限更新
    @role.update_permission(params[:permissions], params[:first_mune])
    redirect_to :back, notice: "操作成功"
  end

  def collection_permission #收集权限
    RolePermission.scan_controllers
    redirect_to :back, notice: "权限收集成功"
  end

  private
    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:name, :comment)
    end
end
