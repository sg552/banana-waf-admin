class IpForMember < ApplicationRecord
	belongs_to :ip
	belongs_to :member
end
