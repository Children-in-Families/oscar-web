class RegistrationsController < Devise::RegistrationsController
  before_action :notify_user, only: [:edit]
  before_action :set_paper_trail_whodunnit

  def new
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def create
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    preferred_language_was = resource.preferred_language
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      I18n.locale = params[:locale] = resource.preferred_language if current_user == resource && resource.preferred_language != preferred_language_was

      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected

  def update_resource(resource, params)
    if params[:program_warning].present? || params[:domain_warning].present?
      resource.update_without_password(params)
    else
      super
    end
  end

  def after_update_path_for(resource)
    if params[:user][:program_warning].present?
      flash[:notice] = nil
      program_streams_path
    elsif params[:user][:domain_warning].present?
      flash[:notice] = nil
      domains_path
    else
      super
    end
  end

  private

  def notify_user
    @lazy_load_notification = true
  end
end
