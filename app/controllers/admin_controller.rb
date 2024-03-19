class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user

  protected

  def notify_user
    if preload_notifications?
      @notification = current_user.fetch_notification
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
