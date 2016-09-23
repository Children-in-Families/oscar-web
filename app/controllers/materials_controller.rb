class MaterialsController < AdminController
  load_and_authorize_resource

  before_action :find_material, only: [:edit, :update, :destroy]

  def index
    @materials = Material.order(:status).paginate(page: params[:page], per_page: 20)
  end

  def new
    @material = Material.new
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to materials_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @material.update_attributes(material_params)
      redirect_to materials_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @material.destroy
      redirect_to materials_url, notice: t('.successfully_deleted')
    else
      redirect_to materials_url, notice: t('.unsuccessfully_deleted')
    end
  end

  private

  def material_params
    params.require(:material).permit(:status)
  end

  def find_material
    @material = Material.find(params[:id])
  end
end
