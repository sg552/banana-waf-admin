class AddIndexAttributionToIps < ActiveRecord::Migration[6.0]
  def change
    add_index :ips, :attribution
  end
end
