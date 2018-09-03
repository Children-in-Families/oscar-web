class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :remove_remember_me, :authenticate_user!
  before_action :notify_user, :set_sidebar_basic_info

  protected

  def remove_remember_me
    if user_signed_in? && current_user.last_sign_in_at < 1.week.ago
      current_user.forget_me!
      sign_out current_user
    end
  end

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
