class LoginAttemp < CadexBase
	belongs_to :member, foreign_key: :member_id
	belongs_to :manager, foreign_key: :member_id
end
