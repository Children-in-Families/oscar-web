class ReferralsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  # before_action :find_referred_to_ngo, only: :index

  def index
    @referrals = @client.referrals.where(referred_to: params[:ngo])
  end

  def create
    @referral = @client.referrals.new(referral_params)
    if @referral.save
      redirect_to @client, notice: t('.successfully_created')
    else
      redirect_to @client, alert: t('.failed_create')
    end
  end

  def edit
    @referral = Referral.find(params[:id])
  end

  def update
    @referral = Referral.find(params[:id])

    if @referral.update_attributes(referral_params)
      redirect_to client_referrals_path(@client, ngo: @referral.referred_to), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  # def find_referred_to_ngo
  #   @referred_to_ngo = Organization.find_by(short_name: params[:ngo])
  #   raise ActionController::RoutingError.new('Not Found') if @referred_to_ngo.nil?
  # end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def referral_params
    params.require(:referral).permit(:referred_to, :referred_from, :name_of_referee, :referral_phone, :date_of_referral, :referral_reason, :client_name, :slug)
  end
end
