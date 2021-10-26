class CreateHistoryIpsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :history_ips do |t|
      t.integer :member_id, comment: '登陆用户ID'
      t.string :ip, comment: '登陆IP'
      t.integer :manager_id, comment: '管理员ID'
      t.datetime :logged_at, comment: '登陆时间'
      t.string :region, comment: '地区'
      t.string :city, comment: '城市'
      t.text :address, comment: '地址'

      t.timestamps null: false
    end
  end
end
