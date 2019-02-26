class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user, :set_sidebar_basic_info

  protected

  def notify_user
    clients = Client.accessible_by(current_ability).non_exited_ngo
    @notification = UserNotification.new(current_user, clients)
  end

  def set_sidebar_basic_info
    @client_count  = Client.accessible_by(current_ability).count
    @family_count  = Family.accessible_by(current_ability).count
    @user_count    = User.accessible_by(current_ability).count
    @partner_count = Partner.count
    @agency_count  = Agency.count
    @referral_source_count = ReferralSource.count
  end
end
