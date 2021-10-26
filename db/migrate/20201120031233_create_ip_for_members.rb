class CreateIpForMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_for_members do |t|
      t.integer :ip_id, commit: 'ip表ID'
      t.integer :member_id, commit: 'ip 对应的用户ID'

      t.timestamps
    end
    add_index :ip_for_members, :ip_id
    add_index :ip_for_members, :member_id
    add_index :ip_for_members, [:ip_id, :member_id]
  end
end
