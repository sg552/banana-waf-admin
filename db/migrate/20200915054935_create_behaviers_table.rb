class CreateBehaviersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :behaviers do |t|
      t.string :url
      t.string :behavier_name
      t.string :http_method
      t.timestamps null: false
    end
  end
end
