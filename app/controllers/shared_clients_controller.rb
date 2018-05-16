class SharedClientsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_referred_to_ngo, only: :index

  def index
    # @shared_clients = @client.shared_clients.filter(params[:ngo])
    @shared_clients = @client.shared_clients.where(referred_to: params[:ngo])
  end

  def create
    @shared_client = @client.shared_clients.new(shared_client_params)
    if @shared_client.save
      redirect_to @client, notice: t('.successfully_created')
    else
      redirect_to @client, alert: t('.failed_create')
    end
  end

  def update
    @shared_client = @client.shared_clients.find(params[:id])

    if @shared_client.update_attributes(shared_client_params)
      redirect_to @client, notice: t('.successfully_updated')
    else
      redirect_to @client, alert: t('.failed_update')
    end
  end

  private

  def find_referred_to_ngo
    @referred_to_ngo = Organization.find_by(short_name: params[:ngo])
    raise ActionController::RoutingError.new('Not Found') if @referred_to_ngo.nil?
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def shared_client_params
    params.require(:shared_client).permit(:referred_to, :referred_from, :name_of_referee, :referral_phone, :date_of_referral, :origin_ngo, :referral_reason)
  end
end
