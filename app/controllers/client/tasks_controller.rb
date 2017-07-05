class Client::TasksController < AdminController

  load_and_authorize_resource
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
        domain     = Domain.find(task_params[:domain_id])
        title    = "#{domain.name} - #{task_params[:name]}"
        
        start_date = task_params[:completion_date]
        end_date   = (task_params[:completion_date].to_date + 1.day).to_s
        Calendar.create(title: title, start_date: start_date, end_date: end_date, user_id: current_user.id)
        
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
    task_name = @task.name
    domain     = Domain.find(@task.domain_id)
    title    = "#{domain.name} - #{task_name}"
    start_date = @task.completion_date.to_s
    end_date   = (@task.completion_date + 1.day).to_s
    if @task.update_attributes(task_params)
      if current_user.calendar_integration?
        param_task_name = task_params[:name]
        param_domain_name     = Domain.find(task_params[:domain_id])
        param_title    = "#{param_domain_name.name} - #{param_task_name}"
        param_start_date = task_params[:completion_date]
        param_end_date   = (task_params[:completion_date].to_date + 1.day).to_s
        calendar = Calendar.find_by(title: title, start_date: start_date, end_date: end_date)
        calendar.update(title: param_title, start_date: param_start_date, end_date: param_end_date, sync_status: false) if calendar.present?
      end
      redirect_to client_tasks_path(@client), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @task = @client.tasks.find(params[:id])
    task_name = @task.name
    domain     = Domain.find(@task.domain_id)
    title    = "#{domain.name} - #{task_name}"
    start_date = @task.completion_date.to_s
    end_date   = (@task.completion_date + 1.day).to_s
    respond_to do |format|
      if @task.destroy
        if current_user.calendar_integration?
          calendar = Calendar.find_by(title: title, start_date: start_date, end_date: end_date)
          calendar.destroy if calendar.present?
        end
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
end
