class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user

  protected

  def notify_user
    if params[:user_id] || controller_name == 'notifications'
      clients = Client.none.accessible_by(current_ability).non_exited_ngo
      @notification = UserNotification.new(current_user, clients)
    else
      @lazy_load_notification = true
    end
  end
end
