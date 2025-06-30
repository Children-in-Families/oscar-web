class Client::EnterNgosController < AdminController
  before_action :find_client

  def create
    @enter_ngo = @client.enter_ngos.new(enter_ngo_params)
    if !@client.accepted? && @enter_ngo.save
      @enter_ngo.reload
      ReferralHistory.create(referral_history_params.merge(client_id: @client.id, enter_ngo_id: @enter_ngo.id, user_ids: @enter_ngo.user_ids))
      redirect_to @client, notice: t('.successfully_created')
    else
      redirect_to @client, alert: t('.failed_create')
    end
  end

  def update
    @enter_ngo = @client.enter_ngos.find(params[:id])
    authorize @enter_ngo

    if !@client.accepted? && @enter_ngo.update_attributes(enter_ngo_params)
      ReferralHistory.update_attributes(referral_history_params.merge(client_id: @client.id, enter_ngo_id: @enter_ngo.id, user_ids: @enter_ngo.user_ids))
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
    params.require(:enter_ngo).permit(:accepted_date, :referral_date, :follow_up_date, :received_by_id, :followed_up_by_id, user_ids: [])
  end

  def referral_history_params
    params.require(:enter_ngo).permit(:client_id, :enter_ngo_id, :referral_date, :follow_up_date, :received_by_id, :followed_up_by_id, user_ids: [])
  end
end
