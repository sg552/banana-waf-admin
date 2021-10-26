class Manager < CadexBase

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role
  has_many :blocked_ips, foreign_key: :blocked_by
  has_many :unblocked_ips, foreign_key: :unblocked_by
  has_many :login_attemps, foreign_key: :member_id
  def permissions
    Permission.where('user_entity_class = "Manager" and user_entity_id = ?', id)
  end

  def roles
    permissions.map(&:role)
  end

  def get_otp_code
    ROTP::TOTP.new(self.opt_secret, issuer: ENV['GOOGLE_OTP_ISSUER']).now
  end

  def is_super_super_admin
    true
  end

  def max_login_attemps_error?
    SystemVariable.find_or_create_by(name: 'max_failed_manager_login_attemps')
    max_login_attemps = SystemVariable.find_by_name('max_failed_manager_login_attemps').value.to_i
    return false if max_login_attemps.blank?
    login_attemps = self.login_attemps.where(is_invalid: false, os_type: "admin").count
    if login_attemps >= max_login_attemps
      self.update(is_able_to_login: false)
    end
    !self.is_able_to_login
    #return login_attemps >= max_login_attemps
  end

  def record_login_error_msg option
    login_attemps.create!(
      login: option[:login_name],
      # ip: client_ip,
      is_success: false,
      wrong_password: option[:wrong_password],
      comment: {message: option[:msg]},
      os_type: 'admin'
    )
  end

  def able_login
    self.login_attemps.where(is_invalid: false, os_type: "admin").update_all(is_invalid: true)
  end
end
