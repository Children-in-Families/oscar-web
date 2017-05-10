class TasksController < AdminController
  load_and_authorize_resource

  def index
    @tasks = Task.incomplete.of_user(task_of_user)
    @users = find_users.order(:first_name, :last_name)
  end

  private

  def find_users
    if current_user.admin? || current_user.strategic_overviewer?
      User.all
    elsif current_user.manager?
      User.where('id = ? OR manager_id = ?', current_user.id, current_user.id)
    else
      User.in_department(current_user.department_id)
    end
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end
end
