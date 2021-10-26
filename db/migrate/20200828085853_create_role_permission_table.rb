class CreateRolePermissionTable < ActiveRecord::Migration[6.0]
  def change
    create_table :role_permissions do |t|
      t.integer :parent_id, comment: '子关联父级'
      t.string :name, comment: '方法名字'
      t.string :comment, comment: '汉语名称'

      t.timestamps null: false
    end
  end
end
