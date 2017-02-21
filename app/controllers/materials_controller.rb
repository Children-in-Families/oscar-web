class MaterialsController < AdminController
  load_and_authorize_resource

  before_action :find_material, only: [:update, :destroy]

  def index
    @materials = Material.order(:status).page(params[:page]).per(20)
    @results   = Material.count
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to materials_path, notice: t('.successfully_created')
    else
      redirect_to materials_path, alert: t('.failed_create')
    end
  end

  def update
    if @material.update_attributes(material_params)
      redirect_to materials_path, notice: t('.successfully_updated')
    else
      redirect_to materials_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @material.destroy
      redirect_to materials_url, notice: t('.successfully_deleted')
    else
      redirect_to materials_url, notice: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @material = Material.find(params[:material_id])
    @versions = @material.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def material_params
    params.require(:material).permit(:status)
  end

  def find_material
    @material = Material.find(params[:id])
  end
end
