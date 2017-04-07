class PartnerCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_partner
  before_action :set_custom_field
  before_action :set_partner_custom_field, only: [:edit, :show, :destroy]

  def index
    @partner_custom_fields = @partner.partner_custom_fields.by_custom_field(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def show
  end

  def new
    @partner_custom_field = @partner.partner_custom_fields.new(custom_field_id: @custom_field.id)
  end

  def create
    @partner_custom_field                 = @partner.partner_custom_fields.new(partner_custom_field_params)
    @partner_custom_field.custom_field_id = @custom_field.id
    if @partner_custom_field.save
      redirect_to partner_partner_custom_fields_path(@partner, custom_field_id: @partner_custom_field.custom_field.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @partner_custom_field.update(partner_custom_field_params)
      redirect_to partner_partner_custom_fields_path(@partner, custom_field_id: @partner_custom_field.custom_field_id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @partner_custom_field.destroy
    if @partner.partner_custom_fields.by_custom_field(@custom_field).empty?
      redirect_to partner_path(@partner), notice: t('.successfully_deleted')
    else
      redirect_to partner_partner_custom_fields_path(@partner, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
    end
  end

  private

  def partner_custom_field_params
    params.require(:partner_custom_field).permit({}).merge(properties: (params['partner_custom_field']['properties']).to_json)
  end

  def set_partner
    @partner = Partner.find(params[:partner_id])
  end

  def set_custom_field
    if action_name == 'edit' || action_name == 'update'
      @custom_field = @partner_custom_field.custom_field
    elsif action_name == 'create'
      @custom_field = CustomField.find(params[:partner_custom_field][:custom_field_id])
    else
      @custom_field = CustomField.find(params['custom_field_id'])
    end
  end

  def set_partner_custom_field
    @partner_custom_field = @partner.partner_custom_fields.find(params[:id])
  end
end
