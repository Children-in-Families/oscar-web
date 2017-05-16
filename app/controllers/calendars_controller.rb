class CalendarsController < AdminController
  def redirect
    client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                        client_secret: Rails.application.secrets.google_client_secret,
                                        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                        scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
                                        redirect_uri: callback_url)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    if params[:error].present?
      redirect_to session[:referrer]
    else
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                          redirect_uri: callback_url,
                                          code: params[:code])
      response = client.fetch_access_token!
      current_user.update(expires_at: DateTime.now + response['expires_in'].seconds)
      session[:authorization] = response
      redirect_to session[:referrer]
    end
  end

  def index
    if session[:referrer].present?
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      calendars = current_user.calendars
      calendars.each do |event_list|
        event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.start_date.to_date.to_s),
                                                    end: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.end_date.to_date.to_s),
                                                    summary: event_list.title)
        service.insert_event('primary', event)
      end
      session[:referrer] = nil
    end
  end

  def new
    task      = Task.find(params[:task])
    domain    = Domain.find(task.domain_id)
    summary    = "#{domain.name} - #{task.name}"
    start_date = task.completion_date.to_s
    end_date   = (task.completion_date + 1).to_s
    @calendar = Calendar.create(title: summary, start_date: start_date, end_date: end_date, user_id: current_user.id)
    if params[:client].present?
      redirect_to client_tasks_path(params[:client]), notice: t('add_event_success')
    else
      redirect_to tasks_path, notice: t('add_event_success')
    end
  end

  def all_new
    tasks = []
    if params[:grouped_tasks] == 'upcoming'
      tasks = find_tasks.upcoming
    elsif params[:grouped_tasks] == 'today'
      tasks = find_tasks.today
    elsif params[:grouped_tasks] == 'overdue'
      tasks = find_tasks.overdue
    end
    tasks.each do |task|
      domain    = Domain.find(task.domain_id)
      summary    = "#{domain.name} - #{task.name}"
      start_date = task.completion_date.to_s
      end_date   = (task.completion_date + 1).to_s
      Calendar.create(title: summary, start_date: start_date, end_date: end_date, user_id: current_user.id)
    end
    if params[:client].present?
      redirect_to client_tasks_path(params[:client]), notice: t('add_event_success')
    else
      redirect_to tasks_path, notice: t('add_event_success')
    end
  end

  def sync
    if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
      session[:referrer] = request.referrer
      redirect_to redirect_path
    else
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      calendars = current_user.calendars
      calendars.each do |event_list|
        event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.start_date.to_date.to_s),
                                                    end: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.end_date.to_date.to_s),
                                                    summary: event_list.title)
        service.insert_event('primary', event)
      end
      redirect_to events_path, notice: t('add_event_success')
    end
  end

  def find_event
    render json: current_user.calendars
  end

  private

  def find_tasks
    Task.incomplete.of_user(current_user)
  end
end
