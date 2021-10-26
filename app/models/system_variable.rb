class SystemVariable < ApplicationRecord

  def self.set options
    name = options[:name]
    value = options[:value]
    comment = options[:comment]

    v = SystemVariable.find_by_name name rescue nil
    if v.blank?
      v = SystemVariable.new name: name, value: value, comment: comment
    end
    v.value = value
    v.comment = comment
    v.save!

    Rails.cache.write name, value
  end

  def self.get name
    Rails.cache.fetch(name) do
      SystemVariable.find_by_name(name).value rescue ''
    end
  end
end
