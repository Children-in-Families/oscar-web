class Client::TasksController < ApplicationController

  before_action :find_client

  def index
    @tasks = @client.tasks
  end

  def new
    @task = @client.tasks.new
  end

  def create
    @task = @client.tasks.new(task_params)
    @task.user_id = @client.user.id if @client.user
    if @task.save
      redirect_to client_tasks_path(@client), notice: 'Task has successfully been created'
    else
      render :new
    end
  end

  def edit
    @task = @client.tasks.find(params[:id])
  end

  def update
    @task = @client.tasks.find(params[:id])
    if @task.update_attributes(task_params)
      redirect_to client_tasks_path(@client), notice: 'Task has successfully been updated'
    else
      render :edit
    end
  end

  def destroy
    @task = @client.tasks.find(params[:id])
    @task.destroy
    redirect_to client_tasks_path(@client), notice: 'Task has successfully been deleted'
  end

  private
  def find_client
    if current_user.admin?
      @client = Client.find(params[:client_id])
    elsif current_user.case_worker?
      @client = current_user.clients.find(params[:client_id])
    end
  end

  def task_params
    params.require(:task).permit(:domain_id, :name, :completion_date, :remind_at)
  end
end
