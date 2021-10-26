module Private
  class ManagementsController < BaseController #首页
    def index
      cookies[:selected_menu] = ""
    end
  end
end
