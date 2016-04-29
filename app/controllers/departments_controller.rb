class DepartmentsController < AdminController
  load_and_authorize_resource

  before_action :find_department, only: [:edit, :update, :destroy]

  def index
    @departments = Department.all.paginate(page: params[:page], per_page: 20)
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)
    if @department.save
      redirect_to departments_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @department.update_attributes(department_params)
      redirect_to departments_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @department.users_count.zero?
      @department.destroy
      redirect_to departments_url, notice: t('.successfully_deleted')
    else
      redirect_to departments_url, alert: t('.alert')
    end
  end

  private

  def department_params
    params.require(:department).permit(:name, :description)
  end

  def find_department
    @department = Department.find(params[:id])
  end
end
