class Role < ApplicationRecord

  require 'json'
	has_many :managers

  # 默认用户可操作的方法
  DEFAULT_CONTROLLER = ["sessions", "managers", "managements"]
  DEFAULT_ACTION = {managements: 'index'}
  NOT_PERMISSION = {managers: 'index'}

  def update_permission(role_permission_ids, first_mune)
    if first_mune
      first_mune = first_mune.join(',')
    else
      first_mune = ""
    end
    self.update(role_permission_ids: (role_permission_ids).to_json, first_level_menu_permission: first_mune)
  end

  def self.update_role_permission_ids(controller_ids_arr, action_ids_arr)

    Role.all.each do |role|
      next unless role.role_permission_ids.present?
      role_permission_ids = JSON(role.role_permission_ids)
      result_delete_controller_permission =
        Role.delete_controller_id(role_permission_ids, controller_ids_arr)
      result_delete_action_permission =
        Role.delete_action_id(result_delete_controller_permission, action_ids_arr)

      role.role_permission_ids = result_delete_action_permission.to_json
      role.save
    end
  end

  def self.delete_controller_id(role_permission_ids, controller_ids_arr)
    controller_permission_ids_hash = {}
    controller_ids_arr.each do |controller_id|
      role_permission_ids.delete(controller_id.to_s)
    end
    controller_permission_ids_hash.merge!(role_permission_ids) if role_permission_ids.present?
    controller_permission_ids_hash
  end

  def self.delete_action_id(result_delete_controller_permission, action_ids_arr)
    action_permission_ids_hash = {}
    return if result_delete_controller_permission.empty?
    result_delete_controller_permission.each do |k, v|
      action_ids = v - action_ids_arr.map(&:to_s)
      if !action_ids.empty?
        action_permission_ids_hash[k] = v - action_ids_arr.map(&:to_s)
      else
        RolePermission.find_by_id(k.to_i).delete
      end
    end
    action_permission_ids_hash = action_permission_ids_hash.empty? ? "" : action_permission_ids_hash
  end

  def permissions(controller, action)
    # 超级管理员默认拥有所有权限
    return true if name == 'super_admin'
    # 特殊功能需要默认开放
    if DEFAULT_CONTROLLER.include?(controller) || DEFAULT_ACTION[controller.to_sym] == action
      return false if NOT_PERMISSION[controller.to_sym] && NOT_PERMISSION[controller.to_sym] == action
      return true
    end
  	permission = false
  	controller_name_and_action_name = {}
  	return permission if role_permission_ids == nil || role_permission_ids == "null"
  	JSON(role_permission_ids).each do |k, v|
  		role_permission = RolePermission.find_by_id(k)
  		controller_name_and_action_name[role_permission.name] = RolePermission.where(id: v).pluck(:name) if role_permission
  	end
  	permission = controller_name_and_action_name[controller].include?(action) rescue false
	  permission
  end

  def self.get_first_class_menu
    # 做权限使用，不得调换位置，如果增加新的一级菜单，往后面直接添加即可
    {
      '1'=> I18n.t("header.members"),
      '2' =>  I18n.t("header.crypto_transaction"),
      '3' =>  I18n.t("header.system"),
    }
  end
end
