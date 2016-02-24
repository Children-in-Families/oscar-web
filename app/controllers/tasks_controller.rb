class TasksController < ApplicationController
  def index
    @tasks = current_user.admin? ? Task.incomplete.filter(params) : Task.incomplete.of_user(current_user)
    @users = User.order(:first_name, :last_name)
    @user  = User.find(params[:user_id]) if params[:user_id]
  end
end
