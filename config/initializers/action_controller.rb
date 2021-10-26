# ActionController::Base are used by Peatio controllers.
class ActionController::Base

  before_action :set_language

  private

  def set_language
    full_locales = ['en', 'zh', 'jp', 'kr', 'ru', 'русский']
    if params[:lang].present? && !(full_locales.include?(params[:lang]))
      params[:lang] = 'zh'
    end
    
    cookies[:cadex_admin_lang] = params[:lang] unless params[:lang].blank?
    locale = cookies[:cadex_admin_lang] || 'zh'
    I18n.locale = locale if locale && I18n.available_locales.include?(locale.to_sym)
    logger.info "== locale: #{locale}, I18n.locale: #{ I18n.locale} "
  end

  def set_redirect_to
    if request.get?
      uri = URI(request.url)
      cookies[:redirect_to] = "#{uri.path}?#{uri.query}"
    end
  end

end
