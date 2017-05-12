class TasksController < AdminController
  load_and_authorize_resource

  def index
    @tasks = Task.incomplete.of_user(task_of_user)
    @users = find_users.order(:first_name, :last_name)
    if session[:action] == 'new'
      task      = Task.find(session[:task_id])
      domain    = Domain.find(task.domain_id)
      summary    = "#{domain.name} - #{task.name}"
      start_date = task.completion_date.to_s
      end_date   = (task.completion_date + 1).to_s
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
                                                  end: Google::Apis::CalendarV3::EventDateTime.new(date: end_date),
                                                  summary: summary)
      service.insert_event('primary', event)
      session[:task_id] = nil
      session[:action] = nil
      flash[:notice] = t('add_event_success')
    elsif session[:action] == 'all_new'
      tasks = @tasks.incomplete.upcoming
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      tasks.each do |task|
        domain    = Domain.find(task.domain_id)
        summary    = "#{domain.name} - #{task.name}"
        start_date = task.completion_date.to_s
        end_date   = (task.completion_date + 1).to_s
        event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
                                                    end: Google::Apis::CalendarV3::EventDateTime.new(date: end_date),
                                                    summary: summary)
        service.insert_event('primary', event)
      end
      session[:action] = nil
      flash[:notice] = t('add_event_success')
    end
  end

  private

  def find_users
    User.self_and_subordinates(current_user)
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end
end
