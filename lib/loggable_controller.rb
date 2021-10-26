module LoggableController
  def save_log
    controller = params[:controller]
    action = params[:action]
    request_type = restful_method(params)
    return  if restful_method(params) == 'get'
    OperationLog.create!(:action => action, :controller => controller,
        :user_name => current_manager.try(:email),
        :parameters =>  params.inspect,
        :remote_ip=> request.remote_ip,
        :restful_method => restful_method(params)
    )
  end

  private

  # return: get, post, put or delete
  def restful_method(params)
    return request.method.downcase
   #params[:authenticity_token].blank? ? 'get' : ((params[:_method]) || 'post')
  end
end
