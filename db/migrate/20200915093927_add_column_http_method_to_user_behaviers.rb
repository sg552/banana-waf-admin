class AddColumnHttpMethodToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :http_method, :string
  end
end
