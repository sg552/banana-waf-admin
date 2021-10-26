class CreateUrlVisitLimitsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :url_visit_limits do |t|
      t.integer :behavier_id
      t.integer :maximum_times, index: true, default: 0, commit:"单位时间访问的最大次数"
      t.string :duration, commit:"单位时间"

      t.timestamps null: false
    end
  end
end
