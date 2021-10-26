class Managers::PasswordsController < Devise::PasswordsController
  before_action :current_login
   def new
     super
   end

   def create
     m = Manager.find_by_phone params[:manager][:phone]
     if m.present? && params[:new_password].present?
       m.password = params[:new_password]
       m.save
       render json: { path: '/managers/sign_in' } and return
     end
     if m.blank? || m.token != params[:manager][:token]
       render :json => {
         error: '500',
         message: '接口异常'
       }, status: 500 and return
     end
     render :file => "/managers/passwords/create.js.erb"
   end

end
