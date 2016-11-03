class RegistrationsController < Devise::RegistrationsController

  before_action :notify_user, only: [:edit, :update]

  def new
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def create
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  private

  def notify_user
    @notification = UserNotification.new(current_user)
  end
end
