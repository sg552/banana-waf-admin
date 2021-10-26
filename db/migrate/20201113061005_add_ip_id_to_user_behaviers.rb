class AddIpIdToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :ip_id, :integer
  end
end
