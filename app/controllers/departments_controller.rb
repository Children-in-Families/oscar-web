class DepartmentsController < AdminController
  load_and_authorize_resource

  before_action :find_department, only: [:update, :destroy]

  def index
    @departments = Department.order(:name).page(params[:page]).per(20)
    @results     = Department.count
  end

  def create
    @department = Department.new(department_params)
    if @department.save
      redirect_to departments_path, notice: t('.successfully_created')
    else
      redirect_to departments_path, alert: t('.failed_create')
    end
  end

  def update
    if @department.update_attributes(department_params)
      redirect_to departments_path, notice: t('.successfully_updated')
    else
      redirect_to departments_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @department.users.count.zero?
      @department.destroy
      redirect_to departments_url, notice: t('.successfully_deleted')
    else
      redirect_to departments_url, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @department = Department.find(params[:department_id])
    @versions   = @department.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def department_params
    params.require(:department).permit(:name, :description)
  end

  def find_department
    @department = Department.find(params[:id])
  end
end
