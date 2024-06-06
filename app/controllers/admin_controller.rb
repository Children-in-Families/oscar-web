class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user

  protected

  def notify_user
    if preload_notifications?
      if !request.xhr? && request.path == '/notifications/referrals'
        clients = Client.none.accessible_by(current_ability).non_exited_ngo
        @notification = UserNotification.new(current_user, clients)
      else
        @notification = current_user.fetch_notification unless request.xhr?
      end
    else
      @lazy_load_notification = true
    end
  end

  def preload_notifications?
    controller_name == 'notifications' ||
      (dashboard_request? && (params[:user_id] || current_user.case_worker? || current_user.manager?))
  end

  def dashboard_request?
    controller_name == 'dashboards' && action_name == 'index'
  end
end
