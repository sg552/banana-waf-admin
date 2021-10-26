class CreateWhiteIpTables < ActiveRecord::Migration[6.0]
  def change
    create_table :white_ips do |t|
      t.string :ip
      t.string :remark, commit: '备注'
      t.timestamps null: false
    end
  end
end
