class AddIpIdToBlockedIps < ActiveRecord::Migration[6.0]
  def change
    add_column :blocked_ips, :ip_id, :integer
  end
end
