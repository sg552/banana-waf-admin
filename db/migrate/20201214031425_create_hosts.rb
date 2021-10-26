class CreateHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :hosts do |t|
      t.string :name, comment: "域名名称"

      t.timestamps
    end
  end
end
