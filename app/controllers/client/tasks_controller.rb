class Client::TasksController < AdminController
  load_and_authorize_resource
  before_action :find_client

  def index
    @tasks = @client.tasks
    if session[:task_id].present?
      task      = Task.find(session[:task_id])
      domain    = Domain.find(task.domain_id)
      summary    = "#{domain.name} - #{task.name}"
      start_date = task.completion_date.to_s
      end_date   = (task.completion_date + 1).to_s
      primary_calendar_id = ''
      events = ''
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service.list_events('primary').items.each do |event|
        if event.summary == summary
          events << event.summary
          break
        end
      end
      if events.present?
        session[:task_id] = ''
        redirect_to url_for, alert: t('has_been_added_to_calendar')
      else
        event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
                                                    end: Google::Apis::CalendarV3::EventDateTime.new(date: end_date),
                                                    summary: summary)
        service.insert_event('primary', event)
        session[:task_id] = ''
        flash[:notice] = t('add_event_success')
      end
    end
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
    if current_user.calendar_integration?
      task_name       = @task.name
      domain_name     = Domain.find(@task.domain_id).name
      completion_date = @task.completion_date.to_s
    end
    if @task.update_attributes(task_params)
      if current_user.calendar_integration?
        if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
          session[:referrer] = url_for
          redirect_to redirect_path
        else
          param_task_name = task_params[:name]
          param_domain_name = Domain.find(task_params[:domain_id]).name
          param_completion_date = task_params[:completion_date]
          summary    = "#{domain_name} - #{task_name}"

          client = Signet::OAuth2::Client.new(client_id: '304280597205-m9d4o2bcnkrjf6gr7p6n1khufdskv4kv.apps.googleusercontent.com',
                                              client_secret: '0pdcBK3xm_RlcVvUHYTZ2NVs',
                                              token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
          client.update!(session[:authorization])
          service = Google::Apis::CalendarV3::CalendarService.new
          service.authorization = client
          service.list_events('primary').items.each do |event|
            event_start_date = event.start.date || event.start.date_time
            if event.summary == summary && event_start_date == completion_date
              event.summary    = "#{param_domain_name} - #{param_task_name}"
              event.start.date = param_completion_date
              event.end.date   = (param_completion_date.to_date + 1.day).to_s
              service.update_event('primary', event.id, event)
              break
            end
          end
          redirect_to client_tasks_path(@client), notice: t('.successfully_updated')
        end
      else
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
        task_name       = @task.name
        domain_name     = Domain.find(@task.domain_id).name
        completion_date = @task.completion_date.to_s
        summary    = "#{domain_name} - #{task_name}"
        client = Signet::OAuth2::Client.new(client_id: '304280597205-m9d4o2bcnkrjf6gr7p6n1khufdskv4kv.apps.googleusercontent.com',
                                            client_secret: '0pdcBK3xm_RlcVvUHYTZ2NVs',
                                            token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
        client.update!(session[:authorization])
        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = client
        service.list_events('primary').items.each do |event|
          event_start_date = event.start.date || event.start.date_time
          if event.summary == summary && event_start_date == completion_date
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
