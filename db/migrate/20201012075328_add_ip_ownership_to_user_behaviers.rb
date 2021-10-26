class AddIpOwnershipToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :ip_ownership, :string, commit: 'ip 归属地'
    add_column :white_ips, :ip_ownership, :string, commit: 'ip 归属地'
  end
end
