Rails.application.routes.draw do

  root 'private/managements#index'

  resources :roles do
    collection do
      get :setting_role_permission
      post :update_role_permission
      get :collection_permission
    end
  end

  resources :real_time_monitorings do
    collection do
      get :local_running_progress
    end
  end

  resources :progress_monitors

  resources :members do
    collection do
    end
  end

  scope module: :private do
    resources :system_variables do
      collection do
        get :setting_default_locale
        post :create_and_new_locale
        get :setting_manager_login_attemps
        post :creat_manager_login_attemps
      end
    end

    resources :login_attemps do
      collection do
        get :download_csv
        get :ip_login_error_count
        get :device_login_error_count
        get :member_login_error_count
      end
    end

    resources :white_ips do
      collection do
        get :download_csv
      end
    end
    resources :devices do
      collection do
        get :download_csv
      end
    end
    resources :blocked_ips do
      collection do
        post :unblocked
        post :blocked
        get :download_csv
      end
    end
    resources :url_visit_limits do
      collection do
        post :update_data
        get :download_csv
      end
    end

    resources :user_behaviers do
      collection do
        get :ip_statistical_analysis
        get :ip_statistical_analysis_user_show
        get :user_behavier_access_analysis
        get :user_behavier_access_analysis_show
        get :download_csv
        get :download_csv_ip_statistical_analysis
        get :download_user_behavier_access_analysis
      end
    end
    resources :behaviers do
      collection do
        post :update_data
        get :download_csv
      end
    end

    resources :sensitive_words do
      collection do
      end
    end
  end


  resources :database_monitors do
  end

  resources :managers, only: [:index] do
    collection do
      post :update_manager_role
      post :update_able_login
    end
    member do
      get :edit_permissions
      get :edit_password
      put :update_password
      get :edit_google_otp
      put :update_google_otp
      get :edit_information
      post :update_information
    end
  end
  devise_for :managers, controllers: {
    registrations: 'managers/registrations',
    passwords: 'managers/passwords',
    sessions: 'managers/sessions'
  }
end
