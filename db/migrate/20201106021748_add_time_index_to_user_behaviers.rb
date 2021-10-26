class AddTimeIndexToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_index :user_behaviers, :time
  end
end
