class CreateBlockedIpsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_ips do |t|
      t.string :ip, index: true, commit:"被封的ip"
      t.integer :blocked_by, index: true, default: 0, commit: "被谁封禁的（后台管理员ID或 0:代码脚本）"
      t.text :blocked_reason, commit: "封禁的理由"
      t.integer :unblocked_by, index:true, commit: "被谁解封"
      t.string :unblocked_reason, commit: "解封的理由"
      t.text :comment, commit: "加的注释 . 例如 这个ip貌似是个局域网的IP"
      t.string :address, commit: "该IP所属位置信息"
      t.boolean :is_blocked, index:true, default: true, commit: "是否被封禁( 是 表示封禁生效中 .否: 表示封禁被解封了)"
      t.datetime :unblocked_at, index:true, commit: "解封时间"

      t.timestamps null: false
    end
  end
end
