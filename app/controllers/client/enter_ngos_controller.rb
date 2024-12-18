class Client::EnterNgosController < AdminController
  before_action :find_client

  def create
    @enter_ngo = @client.enter_ngos.new(enter_ngo_params)

    if !@client.accepted? && @enter_ngo.save
      redirect_to @client, notice: t('.successfully_created')
    else
      redirect_to @client, alert: t('.failed_create')
    end
  end

  def update
    @enter_ngo = @client.enter_ngos.find(params[:id])
    authorize @enter_ngo

    if !@client.accepted? && @enter_ngo.update_attributes(enter_ngo_params)
      redirect_to @client, notice: t('.successfully_updated')
    else
      redirect_to @client, alert: t('.failed_update')
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def enter_ngo_params
    params.require(:enter_ngo).permit(:accepted_date, :follow_up_date, :initial_referral_date, :received_by_id, :followed_up_by_id, user_ids: [])
  end
end
