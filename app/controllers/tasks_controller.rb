class TasksController < AdminController
  load_and_authorize_resource

  def index
    @tasks = Task.incomplete.of_user(task_of_user)
    @users = find_users.order(:first_name, :last_name) unless current_user.case_worker?
  end

  private

  def find_users
    User.self_and_subordinates(current_user)
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end
end
