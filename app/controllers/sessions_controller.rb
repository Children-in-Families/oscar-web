class SessionsController < Devise::SessionsController
  before_action :set_whodunnit, :set_current_ngo, :detect_browser
  after_action :increase_visit_count, only: :create

  def set_whodunnit
    if current_user
      PaperTrail::Version.where(item_id: current_user.id, whodunnit: nil).each do |v|
        v.update(whodunnit: current_user.id)
      end
    end
  end

  def set_current_ngo
    @current_ngo = Organization.current
  end

  def detect_browser
    lang = params[:locale] || locale.to_s
    if browser.firefox? && browser.platform.mac? && lang == 'km'
      flash.clear
      flash[:alert] = "Application is not translated properly for Firefox on Mac, we're sorry to suggest to use Google Chrome browser instead."
    end
  end

  def increase_visit_count
    Visit.create(user: current_user)
  end

  # def create
  #   self.resource = warden.authenticate!(auth_options)
  #
  #   if resource && resource.otp_module_disabled?
  #     super
  #
  #   elsif resource && resource.otp_module_enabled?
  #
  #     if params[:user][:otp_code_token].size > 0
  #       if resource.authenticate_otp(params[:user][:otp_code_token], drift: 60)
  #         super
  #       else
  #         sign_out
  #         redirect_to url_for, alert: t('.bad_credentials_supplied')
  #       end
  #     else
  #       sign_out
  #       redirect_to url_for, alert: t('.your_account_needs_to_supply_a_verification_code')
  #     end
  #   end
  # end
  def create
    resource = User.find_by_email(params[:user][:email])
    if resource && resource.otp_required_for_login?
      if params[:user][:otp_attempt].size > 0
        totp = ROTP::TOTP.new(resource.otp_secret)
        if totp.verify_with_drift(params[:user][:otp_attempt], resource.class.otp_allowed_drift)
          super
        else
          sign_out
          redirect_to url_for, alert: t('.bad_credentials_supplied')
        end
      else
        sign_out
        redirect_to url_for, alert: t('.your_account_needs_to_supply_a_verification_code')
      end
    else
      super
    end
  end
end
