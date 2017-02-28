class ClientCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_client
  before_action :set_custom_field, only: [:new, :index, :destroy]
  before_action :set_client_custom_field, only: [:show, :destroy]
  before_action :set_custom_field_on_create, only: [:create]
  before_action :set_custom_field_on_edit, only: [:edit]

  def edit
    # binding.pry
  end

  def update
    # binding.pry
    if @client_custom_field.update(merged_custom_field_params)
      redirect_to client_client_custom_fields_path(@client, custom_field_id: @client_custom_field.custom_field_id), notice: t('.successfully_created')
    else
      render :edit
    end
  end

  def show
    # binding.pry
  end

  def new
    # binding.pry
    @client_custom_field = @client.client_custom_fields.new(custom_field_id: @custom_field.id)
  end

  def create
    # binding.pry
    @client_custom_field = @client.client_custom_fields.new(client_custom_field_params)
    @client_custom_field.custom_field_id = @custom_field.id
    if @client_custom_field.save
      # binding.pry
      redirect_to client_client_custom_fields_path(@client, custom_field_id: @client_custom_field.custom_field.id)
    else
      # binding.pry
      redirect_to :new
    end
  end

  def index
    # binding.pry
    @client_custom_field = @client.client_custom_fields.by_custom_field_id(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def destroy
    @client_custom_field.destroy
    redirect_to client_client_custom_fields_path(@client, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
  end

  private

  def client_custom_field_params
    # binding.pry
    params.require(:client_custom_field).permit({}).merge(properties: (params['client_custom_field']['properties']).to_json)
  end

  def merged_custom_field_params
    if params['client_custom_field']['properties'].present?
      client_custom_field_params.merge(properties: (params['client_custom_field']['properties']).to_json)
    else
      client_custom_field_params
    end
  end

  protected

  def set_client
    @client = Client.friendly.find(params[:client_id])
  end

  def set_custom_field
    @custom_field = CustomField.find(params['custom_field_id'])
  end

  def set_custom_field_on_create
    @custom_field = CustomField.find(params[:client_custom_field][:custom_field_id])
  end

  def set_custom_field_on_edit
    @custom_field = @client_custom_field.custom_field
  end

  def set_client_custom_field
    @client_custom_field = @client.client_custom_fields.find(params[:id])
  end
end
