class DeviceCreateManagers < ActiveRecord::Migration[6.0]
  def change
    create_table :managers, comment: '管理员表' do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string :phone, comment: '手机'
      t.string :token, comment: '验证码'
      t.datetime :send_token_at, comment: '发送验证码时间'

      t.integer :role_id
      t.string :opt_secret , default: ''
      t.boolean :is_otp_binded, default: false
      t.string :portrait_icon, default: ''
      t.string :nick_name, default: ''
      t.boolean :is_able_to_login, default: true

      t.timestamps null: false
    end
    add_index :managers, :email,                unique: true
    add_index :managers, :reset_password_token, unique: true
  end
end
