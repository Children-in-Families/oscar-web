class DashboardsController < AdminController
  before_action :find_tasks, only: [:index]
  def index
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
  end

private
  def find_tasks
    @tasks = Task.incomplete.exclude_exited_ngo_clients.of_user(task_of_user).uniq
    @users = find_users.order(:first_name, :last_name) unless current_user.case_worker?
  end

  def find_users
    User.self_and_subordinates(current_user)
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end
end
