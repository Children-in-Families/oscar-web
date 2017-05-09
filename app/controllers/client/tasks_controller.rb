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
    task_name      = @task.name
    domain_name    = Domain.find(@task.domain_id).name
    if @task.update_attributes(task_params)
      if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
        redirect_to redirect_path
      else
        param_task_name = task_params[:name]
        param_domain_name = Domain.find(task_params[:domain_id]).name
        summary    = "#{domain_name} - #{task_name}"
        client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                            client_secret: Rails.application.secrets.google_client_secret,
                                            token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
        client.update!(session[:authorization])
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
        service.list_events('primary').items.each do |event|
          if event.summary == summary
            event.summary    = "#{param_domain_name} - #{param_task_name}"
            event.start.date = task_params[:completion_date]
            event.end.date   = (task_params[:completion_date].to_date + 1.day).to_s
            service.update_event('primary', event.id, event)
            break
          end
        end
        redirect_to client_tasks_path(@client), notice: t('.successfully_updated')
      end
    else
      render :edit
    end
  end

  def destroy
    @task = @client.tasks.find(params[:id])
    respond_to do |format|
      if @task.destroy
        task_name      = @task.name
        domain_name    = Domain.find(@task.domain_id).name
        summary    = "#{domain_name} - #{task_name}"
        client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                            client_secret: Rails.application.secrets.google_client_secret,
                                            token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
        client.update!(session[:authorization])
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
        service.list_events('primary').items.each do |event|
          if event.summary == summary
            service.delete_event('primary', event.id)
            break
          end
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
end
