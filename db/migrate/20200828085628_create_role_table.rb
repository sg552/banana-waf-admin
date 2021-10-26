class CreateRoleTable < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :comment
      t.text :role_permission_ids
      t.string :first_level_menu_permission

      t.timestamps null: false
    end
    Role.create name: 'super_admin', comment: '超级管理员'
  end
end
