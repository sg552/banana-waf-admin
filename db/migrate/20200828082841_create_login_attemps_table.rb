class CreateLoginAttempsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :login_attemps do |t|
      t.string :login, comment: '登陆用户名'
      t.string :ip, comment: "ip地址"
      t.boolean :is_success, default: false, comment: '是否登录成功'
      t.text :comment, comment: '注释'
      t.integer :member_id, comment: '关联用户ID'
      t.string :wrong_password
      t.boolean :is_invalid, defalut: false
      t.text :user_agent
      t.string :device_type
      t.string :app_version
      t.string :os_version
      t.string :os_type

      t.timestamps null: false
    end
  end
end
