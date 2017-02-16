class SupplementariesController < AdminController
  before_action :set_client, :set_custom_field

  def edit
  end

  def update
    if @client_custom_field.update(custom_field_params)
      redirect_to @custom_field, notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  private
    def custom_field_params
      params.require(:client_custom_field).permit(:properties)
    end

  protected
    def set_client
      @client = Client.friendly.find(params[:client_id])
    end

    def set_custom_field
      @client_custom_field = @client.client_custom_fields.find(params[:id])
    end
end
