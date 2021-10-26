class CreateUserBehavierTable < ActiveRecord::Migration[6.0]
    def change
      create_table :user_behaviers do |t|
        t.string :ip
        t.integer :member_id
        t.datetime :time, commit: '记录时间'
        t.text :params_text, commit: '参数'
        t.text :cookie
        t.text :user_agent
        t.string :uri
        t.string :host
      end
    end
end
