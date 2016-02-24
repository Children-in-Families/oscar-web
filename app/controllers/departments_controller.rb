class DepartmentsController < ApplicationController
  load_and_authorize_resource

  before_action :find_department, only: [:edit, :update, :destroy]

  def index
    @departments = Department.all
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)
    if @department.save
      redirect_to departments_path, notice: 'កម្មវិធីបង្កើតបានដោយជោគជ័យ / Department has been successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @department.update_attributes(department_params)
      redirect_to departments_path, notice: 'កម្មវិធីSaveបានដោយជោគជ័យ / Department has been successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @department.users_count.zero?
      @department.destroy
      redirect_to departments_url, notice: 'កម្មវិធីត្រូវបានលុបចោលដោយជោគជ័យ / Department has been successfully deleted.'
    else
      redirect_to departments_url, alert: 'Department cannot be deleted.'
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
