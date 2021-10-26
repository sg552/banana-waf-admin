class CreateIps < ActiveRecord::Migration[6.0]
  def change
    create_table :ips do |t|
      t.string :ip_address, index: true, desc: 'ip地址'
      t.string :attribution, desc: '归属地'
      t.float :friendly, default: 0, desc: '友好度'
      t.string :comment, desc: '备注'
    	t.integer :count, default: 0, commit: '此ip的用户数量'
    	t.timestamps null: false
    end
  end
end
