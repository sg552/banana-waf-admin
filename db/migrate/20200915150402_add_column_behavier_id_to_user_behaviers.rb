class AddColumnBehavierIdToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :behavier_id, :integer
  end
end
