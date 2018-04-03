class Client::TasksController < AdminController

  load_and_authorize_resource
  before_action :find_client
  before_action :authorize_client, only: [:new, :create]
  before_action :find_task, only: [:edit, :update, :destroy]

  def index
    @tasks = @client.tasks
  end

  def create
    @task = @client.tasks.new(task_params)
    @task.user_id = current_user.id
    respond_to do |format|
      if @task.save
        Calendar.populate_tasks(@task)

        format.json { render json: @task.to_json, status: 200 }
        format.html { redirect_to client_tasks_path(@client), notice: t('.successfully_created') }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: 422 }
      end
    end
  end

  def edit
  end

  def update
    find_calendars(@task)

    if @task.update_attributes(task_params)
      Calendar.update_tasks(@calendars, task_params) if current_user.calendar_integration? && @calendars.present?

      redirect_to client_tasks_path(@client), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    find_calendars(@task)

    respond_to do |format|
      if @task.destroy
        @calendars.destroy_all if current_user.calendar_integration? && @calendars.present?
      end
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

  def encode32hex(str)
    str.gsub(/\G(.{5})|(.{1,4}\z)/mn) do
      full = $1; frag = $2
      n, c = (full || frag.ljust(5, "\0")).unpack("NC")
      full = ((n << 8) | c).to_s(32).rjust(8, "0")
      if frag
        full[0, (frag.length*8+4).div(5)].ljust(8, "=")
      else
        full
      end
    end
  end

  HEX = '[0-9a-v]'
  def decode32hex(str)
    str.gsub(/\G\s*(#{HEX}{8}|#{HEX}{7}=|#{HEX}{5}={3}|#{HEX}{4}={4}|#{HEX}{2}={6}|(\S))/imno) do
      raise "invalid base32" if $2
      s = $1
      s.tr("=", "0").to_i(32).divmod(256).pack("NC")[0,(s.count("^=")*5).div(8)]
    end
  end

  def find_task
    @task = @client.tasks.find(params[:id])
  end

  def authorize_client
    authorize @client, :create?
  end

  def find_calendars(task)
    task_name  = task.name
    domain     = Domain.find(task.domain_id)
    title      = "#{domain.name} - #{task_name}"
    start_date = task.completion_date
    end_date   = (start_date + 1.day).to_s
    @calendars  = Calendar.where(title: title, start_date: start_date, end_date: end_date)
  end
end
