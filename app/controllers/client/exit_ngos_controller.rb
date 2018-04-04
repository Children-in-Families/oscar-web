class Client::ExitNgosController < AdminController

  before_action :find_client

  def create
    @exit_ngo = @client.exit_ngos.create(exit_ngo_params)
    if @exit_ngo.save
      redirect_to @client, notice: t('.successfully_created')
    else
      render :create
    end
  end

  def update
    @exit_ngo = @client.exit_ngos.find(params[:id])

    if @exit_ngo.update_attributes(exit_ngo_params)
      redirect_to @client, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def edit

  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def exit_ngo_params
    params.require(:exit_ngo).permit( :exit_note, :exit_circumstance, :other_info_of_exit, :exit_date, exit_reasons: [])
  end

end
