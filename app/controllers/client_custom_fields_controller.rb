class ClientCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_client
  before_action :set_custom_field
  before_action :set_client_custom_field, only: [:show, :destroy]
  before_action :restrict_invalid_client_custom_field, only: [:new, :create]

  def index
    @client_custom_fields = @client.client_custom_fields.by_custom_field(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def show
  end

  def new
    @client_custom_field = @client.client_custom_fields.new(custom_field_id: @custom_field.id)
  end

  def create
    @client_custom_field                 = @client.client_custom_fields.new(client_custom_field_params)
    @client_custom_field.custom_field_id = @custom_field.id
    if @client_custom_field.save
      redirect_to client_client_custom_fields_path(@client, custom_field_id: @client_custom_field.custom_field.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @client_custom_field.update(client_custom_field_params)
      redirect_to client_client_custom_fields_path(@client, custom_field_id: @custom_field.id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @client_custom_field.destroy
    if @client.client_custom_fields.by_custom_field(@custom_field).empty?
      redirect_to client_path(@client), notice: t('.successfully_deleted')
    else
      redirect_to client_client_custom_fields_path(@client, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
    end
  end

  private

  def client_custom_field_params
    params.require(:client_custom_field).permit({}).merge(properties: (params['client_custom_field']['properties']).to_json)
  end

  def set_client
    @client = Client.friendly.find(params[:client_id])
  end

  def set_custom_field
    if action_name == 'edit' || action_name == 'update'
      @custom_field = @client_custom_field.custom_field
    elsif action_name == 'create'
      @custom_field = CustomField.find(params[:client_custom_field][:custom_field_id])
    else
      @custom_field = CustomField.find(params['custom_field_id'])
    end
  end

  def set_client_custom_field
    @client_custom_field = @client.client_custom_fields.find(params[:id])
  end

  def restrict_invalid_client_custom_field
    redirect_to client_client_custom_fields_path(@client, custom_field_id: @custom_field.id), alert: t('.cannot_create') unless @client.can_create_next_custom_field?(@client, @custom_field)
  end
end
