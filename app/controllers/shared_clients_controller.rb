class SharedClientsController < AdminController
  load_and_authorize_resource

  before_action :find_client

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

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def shared_client_params
    remove_blank_fields
    params.require(:shared_client).permit(:destination_ngo, :origin_ngo, :referral_reason, fields: [])
  end

  def remove_blank_fields
    return if params[:shared_client][:fields].blank?
    params[:shared_client][:fields].reject!(&:blank?)
  end
end
