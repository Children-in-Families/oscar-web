class PartnerCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_partner, :set_custom_field

  def edit
  end

  def update
    if @partner_custom_field.update(merged_custom_field_params)
      redirect_to partner_partner_custom_field_path(@partner, @partner_custom_field), notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  def show
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
      @partner_custom_field = @partner.partner_custom_fields.find(params[:id])
    end
end
