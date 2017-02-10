class ClientCustomFieldsController < AdminController
  before_action :set_client, :set_custom_field

  def edit
  end

  def update
    if @client_custom_field.update(merged_custom_field_params)
      redirect_to @client, notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  def show
  end

  private
    def custom_field_params
      params.require(:client_custom_field).permit(:properties)
    end

    def merged_custom_field_params
      if params['client_custom_field']['properties'].present?
        custom_field_params.merge(properties: (params['client_custom_field']['properties']).to_json)
      else
        custom_field_params
      end
    end

  protected
    def set_client
      @client = Client.friendly.find(params[:client_id])
    end

    def set_custom_field
      @client_custom_field = @client.client_custom_fields.find(params[:id])
    end
end
