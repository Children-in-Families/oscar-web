class PartnerCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_partner
  before_action :set_custom_field, only: [:new, :index, :destroy]
  before_action :set_partner_custom_field, only: [:edit, :show, :destroy]

  def edit
  end

  def update
    if @partner_custom_field.update(merged_custom_field_params)
      redirect_to partner_partner_custom_fields_path(@partner, custom_field_id: @partner_custom_field.custom_field_id), notice: t('.successfully_created')
    else
      render :edit
    end
  end

  def show
  end

  def new
    @partner_custom_field = @partner.partner_custom_fields.new(custom_field: @custom_field)
    @partner_custom_field.save
  end

  def index
    @partner_custom_field = @partner.partner_custom_fields.by_custom_field_id(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def destroy
    @partner_custom_field.destroy
    redirect_to partner_partner_custom_fields_path(@partner, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
  end

  private

  def custom_field_params
    params.require(:partner_custom_field).permit(:properties)
  end

  def merged_custom_field_params
    if params['partner_custom_field']['properties'].present?
      custom_field_params.merge(properties: (params['partner_custom_field']['properties']).to_json)
    else
      custom_field_params
    end
  end

  protected

  def set_partner
    @partner = Partner.find(params[:partner_id])
  end

  def set_custom_field
    @custom_field = CustomField.find(params['custom_field_id'])
  end

  def set_partner_custom_field
    @partner_custom_field = @partner.partner_custom_fields.find(params[:id])
  end
end
