class UserBehavier < ApplicationRecord
  #belongs_to :limit_url, :foreign_key => 'uri', :class_name => 'UrlVisitLimit'
  belongs_to :member
  belongs_to :ip
  belongs_to :device

  # 大师增加的
  belongs_to :behavier
  
  belongs_to :host

end
