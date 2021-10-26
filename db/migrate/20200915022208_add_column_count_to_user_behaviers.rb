class AddColumnCountToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :visit_count, :integer, default: 1, commit: '访问次数'
  end
end
