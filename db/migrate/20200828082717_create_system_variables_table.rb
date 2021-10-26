class CreateSystemVariablesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :system_variables do |t|
      t.string :name, default: '', comment: '名字,　例如：high_gas_price'
      t.string :value, default: '', comment: '值，例如： 12Gwei'
      t.string :comment, default: '', comment: '注释，例如：最快到账 gas price'
      t.timestamps   null: false
    end
  end
end
