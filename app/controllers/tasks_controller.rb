class TasksController < AdminController
  load_and_authorize_resource

  def index
    @tasks = Task.incomplete.of_user(task_of_user)
    @users = all_user
  end

  private

  def all_user
    if current_user.admin? || current_user.visitor?
      User.order(:first_name, :last_name)
    else
      User.in_department(current_user.department_id).order(:first_name, :last_name)
    end
  end

  def task_of_user
    if params[:user_id]
      User.find(params[:user_id])
    else
      current_user
    end
  end
end
