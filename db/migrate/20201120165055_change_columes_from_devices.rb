class ChangeColumesFromDevices < ActiveRecord::Migration[6.0]
  def change

    remove_column :devices, :os_type
    remove_column :devices, :os_name
    remove_column :devices, :os_version
    remove_column :devices, :borwser_name
    remove_column :devices, :borwser_type
    remove_column :devices, :os_producer
    remove_column :devices, :agent_language
    remove_column :devices, :agent_languageTag
    remove_column :devices, :app_version

    add_column :devices, :ua_type, :string, null: true, default: '', comment: ''
    add_column :devices, :brand, :string, null: true, default: '', comment: ''
    add_column :devices, :brand_name, :string, null: true, default: '', comment: ''

    add_column :devices, :os_name, :string, null: true, default: '', comment: ''
    add_column :devices, :os_code, :string, null: true, default: '', comment: ''
    add_column :devices, :os_family, :string, null: true, default: '', comment: ''
    add_column :devices, :os_family_code, :string, null: true, default: '', comment: ''
    add_column :devices, :os_family_vendor, :string, null: true, default: '', comment: ''
    add_column :devices, :os_url, :string, null: true, default: '', comment: ''
    add_column :devices, :os_icon, :string, null: true, default: ''

    add_column :devices, :is_mobile, :boolean, null: true, default: false
    add_column :devices, :device_type, :string, null: true, default: '', comment: ''
    add_column :devices, :device_brand, :string, null: true, default: '', comment: ''
    add_column :devices, :device_brand_code, :string, null: true, default: '', comment: ''
    add_column :devices, :device_brand_url, :string, null: true, default: '', comment: ''
    add_column :devices, :device_name, :string,  null: true, default: '', comment: ''

    add_column :devices, :browser_name, :string,  null: true, default: '', comment: ''
    add_column :devices, :browser_version, :string,  null: true, default: '', comment: ''
    add_column :devices, :browser_version_major, :string,  null: true, default: '', comment: ''
    add_column :devices, :browser_engine, :string,  null: true, default: '', comment: ''

    add_column :devices, :is_crawler, :boolean, default: false, comment: ''
    add_column :devices, :crawler_category, :string,  null: true, default: '', comment: ''
    add_column :devices, :crawler_last_seen, :string,  null: true, default: '', comment: ''

    add_column :devices, :is_analyzed, :boolean, null: true, default: false
  end
end
