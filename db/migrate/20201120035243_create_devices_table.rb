class CreateDevicesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.text :user_agent, null: false
      t.string :os_type, null: true, default: '', comment: '设备类型 iOS Android Pc ...'
      t.string :os_name, null: true, default: '', comment: '操作系统  苹果x  华为mate ....'
      t.string :os_version, null: true, default: '', comment: '手机版本 ios 14.1  android 8 ...'
      t.string :borwser_name, null: true, default: '', comment: '浏览器名字 '
      t.string :borwser_type, null: true, default: '', comment: '浏览器类型'
      t.string :os_producer, null: true, default: '', comment: '设备生产厂商'
      t.string :agent_language, null: true, default: '', comment: 'English - United States'
      t.string :agent_languageTag, null: true, default: '', comment: 'zh en-us ...'

      t.string :app_version, null: true, default: '', comment: ' WAF Android或iOS APP的版本'
      t.string :comment, null: true, default: '', comment: '备注'
    end
  end
end


