class ChangeColumeUserAgentUserBehaviesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :device_id, :bigint
  end
end
