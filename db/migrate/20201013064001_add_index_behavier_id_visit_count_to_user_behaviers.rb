class AddIndexBehavierIdVisitCountToUserBehaviers < ActiveRecord::Migration[6.0]
  def change
  	add_index :user_behaviers, [:behavier_id, :visit_count]
  	add_index :user_behaviers, [:member_id, :visit_count]
  	add_index :user_behaviers, [:ip, :visit_count]
  	add_index :user_behaviers, [:ip, :member_id]
  end
end
