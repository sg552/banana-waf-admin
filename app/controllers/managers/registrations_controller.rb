class Managers::RegistrationsController < Devise::RegistrationsController
  # before_action :require_no_authentication, except: [:new, :create, :edit, :update]
  before_action :current_login
  # layout "empty", only: [:new]
   def new
     # 注册的时候放开
     if current_manager.blank?
      super
     else
      super
     end
   end

   # def create
   #   Manager.transaction do
   #     super
   #     manager = Manager.find_by_email params[:manager][:email]
   #     manager.phone = params[:manager][:phone]
   #     manager.role_id = 1
   #     manager.save
   #   end
   # end
  def create #创建
    @manager = Manager.new(manager_params)

    @manager.save!
    redirect_to managers_path, notice: '操作成功'
  end

   def edit
     super
   end

   def update
     super
   end

   private
    def set_manager
      @manager = Manager.find(params[:id])
    end

    def manager_params
      params.require(:manager).permit(:email, :password, :phone, :is_able_to_login)
    end
end
