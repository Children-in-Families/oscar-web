class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user, :set_sidebar_basic_info

  protected
    def notify_user
      @notification = UserNotification.new(current_user)
    end

    def set_sidebar_basic_info
      @dashboard = Dashboard.new(current_user)
    end
end
