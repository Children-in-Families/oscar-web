class ClientCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_client
  before_action :set_custom_field, only: [:new, :index, :destroy]
  before_action :set_client_custom_field, only: [:edit, :show, :destroy]

  def edit
  end

  def update
    if @client_custom_field.update(merged_custom_field_params)
      redirect_to client_client_custom_field_path(@client, @client_custom_field), notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  def show
  end

  def new
    @client_custom_field = ClientCustomField.new(custom_field: @custom_field, client: @client)
    if @client_custom_field.save
        # rollback @client_custom_field
      redirect_to edit_client_client_custom_field_path(@client, @client_custom_field), notice: 'Succesfully create new form'
    end
  end

  def index
    @client_custom_field = @client.client_custom_fields.where(custom_field: @custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def destroy
    @client_custom_field.destroy
    redirect_to client_client_custom_fields_path(@client, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
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
      @custom_field = CustomField.find(params['custom_field_id'])
    end

    def set_client_custom_field
      @client_custom_field = @client.client_custom_fields.find(params[:id])
    end
end
