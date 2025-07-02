module LocaleConcern
  def set_locale
    prev_local, local = I18n.locale

    local = params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)

    if detect_browser.present?
      flash.clear
      flash[:alert] = detect_browser
    end
    session[:locale] = local if session[:locale].to_s != params[:local]

    current_local = local || prev_local || session[:locale] || current_user&.preferred_language || I18n.default_locale

    I18n.locale = current_local
  end

  def detect_browser
    lang = params[:locale] || locale.to_s
    if browser.firefox? && browser.platform.mac? && lang == 'km'
      'Khmer fonts for Firefox do not render correctly. Please use Google Chrome browser instead if you intend to use OSCaR in Khmer language.'
    end
  end
end
