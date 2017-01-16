class TasksController < AdminController
  def index
    @tasks = current_user.admin? ? Task.incomplete.filter(params) : Task.incomplete.of_user(current_user)
    @users = get_user
    @user  = User.find(params[:user_id]) if params[:user_id]
  end

	private

  def get_user
  	if current_user.admin?
  		User.order(:first_name, :last_name)
  	else
  		User.in_department(current_user.department_id)
  	end
  end
end
