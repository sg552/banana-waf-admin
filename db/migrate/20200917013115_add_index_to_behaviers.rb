class AddIndexToBehaviers < ActiveRecord::Migration[6.0]
  def change
    add_index :behaviers, :url
  end
end
