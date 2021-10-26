class AddIndexToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_index :user_behaviers, :ip
    add_index :user_behaviers, :uri
    add_index :user_behaviers, :member_id
    add_index :user_behaviers, :http_method
    add_index :user_behaviers, :behavier_id
    add_index :user_behaviers, :host
  end
end
