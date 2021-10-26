class AddHostIdToUserBehavier < ActiveRecord::Migration[6.0]
  def change
    add_column :user_behaviers, :host_id, :integer, index: true, comment: "域名id"
  end
end
