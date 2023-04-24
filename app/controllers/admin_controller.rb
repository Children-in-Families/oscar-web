class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user, :set_sidebar_basic_info

  protected

  def notify_user
    if params[:user_id] || controller_name == 'notifications'
      clients = Client.none.accessible_by(current_ability).non_exited_ngo
      @notification = UserNotification.new(current_user, clients)
    else
      @lazy_load_notification = true
    end
  end

  def set_sidebar_basic_info
    @client_count  = Client.accessible_by(current_ability).count
    @family_count  = Family.accessible_by(current_ability).count
    @community_count  = Community.accessible_by(current_ability).count
    @user_count    = User.where(deleted_at: nil).accessible_by(current_ability).count
    @partner_count = Partner.count
    @agency_count  = Agency.count
    @calls_count   = Call.count
    @referees_count        = Referee.count
    @referral_source_count = ReferralSource.count
  end
end
