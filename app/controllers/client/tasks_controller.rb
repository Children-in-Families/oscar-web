class Client::TasksController < AdminController
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
    respond_to do |format|
      if @task.save
        format.json { render json: @task.to_json, status: 200 }
        format.html { redirect_to client_tasks_path(@client), notice: t('.successfully_created') }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: 422 }
      end
    end
  end

  def edit
    @task = @client.tasks.find(params[:id])
  end

  def update
    @task = @client.tasks.find(params[:id])
    if @task.update_attributes(task_params)
      redirect_to client_tasks_path(@client), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @task = @client.tasks.find(params[:id])
    respond_to do |format|
      @task.destroy
      format.json { head :ok }
      format.html { redirect_to client_tasks_path(@client), notice: t('.successfully_deleted') }
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def task_params
    params.require(:task).permit(:domain_id, :name, :completion_date, :remind_at)
  end
end
