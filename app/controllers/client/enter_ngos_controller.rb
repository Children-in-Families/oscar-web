class EnterNgosController < AdminController

  before_action :find_client

  @enter_ngos = @client.enter_ngos

  def create
    @enter_ngo = @client.enter_ngos.new(enter_ngo_params)
    if @enter_ngo.save
      redirect_to @client, notice: t('.successfully_created')
    else
      render :create
    end
  end

  def update
    if @enter_ngo.update_attributes(enter_ngo_params)
      redirect_to @client, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def enter_ngo_params
    params.require(:enter_ngo).permit( :accepted_date)
  end

end
