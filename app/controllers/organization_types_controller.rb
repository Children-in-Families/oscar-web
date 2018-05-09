class OrganizationTypesController < AdminController
  before_action :authorize_organization_type
  before_action :find_organization_type, only: [:update, :destroy]

  def index
    @organization_types = OrganizationType.order('lower(name)').page(params[:page]).per(20)
    @results   = OrganizationType.count
  end

  def create
    @organization_type = OrganizationType.new(organization_type_params)
    if @organization_type.save
      redirect_to organization_types_path, notice: t('.successfully_created')
    else
      redirect_to organization_types_path, alert: t('.failed_create')
    end
  end

  def update
    if @organization_type.update_attributes(organization_type_params)
      redirect_to organization_types_path, notice: t('.successfully_updated')
    else
      redirect_to organization_types_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @organization_type.partners.count.zero?
      @organization_type.destroy
      redirect_to organization_types_url, notice: t('.successfully_deleted')
    else
      redirect_to organization_types_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @organization_type = OrganizationType.find(params[:organization_type_id])
    @versions = @organization_type.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def organization_type_params
    params.require(:organization_type).permit(:name)
  end

  def find_organization_type
    @organization_type = OrganizationType.find(params[:id])
  end

  def authorize_organization_type
    authorize OrganizationType
  end
end
