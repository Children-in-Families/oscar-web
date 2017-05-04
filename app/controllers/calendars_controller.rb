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
    client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                        client_secret: Rails.application.secrets.google_client_secret,
                                        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                        redirect_uri: callback_url,
                                        code: params[:code])
    response = client.fetch_access_token!
    session[:authorization] = response
    redirect_to dashboards_path
  end

  def index
    redirect_to redirect_path if session[:authorization].blank?
  end

  def new
    if session[:authorization].blank?
      redirect_to redirect_path
    else
      @task      = Task.find(params[:task])
      @domain    = Domain.find(@task.domain_id)
      summary    = "#{@domain.name} - #{@task.name}"
      start_date = @task.completion_date.to_s
      end_date   = (@task.completion_date + 1).to_s
      primary_calendar_id = ''
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
                                                  end: Google::Apis::CalendarV3::EventDateTime.new(date: end_date),
                                                  summary: summary)
      calendars = service.list_calendar_lists.items
      calendars.each do |calendar|
        if calendar.primary == true
          primary_calendar_id = calendar.id
          break
        end
      end
      service.insert_event(primary_calendar_id, event)
      redirect_to client_tasks_path(params[:client]), notice: t('add_event_success')
    end
  end

  def find_event
    client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                        client_secret: Rails.application.secrets.google_client_secret,
                                        token_credential_uri: 'https://accounts.google.com/o/oauth2/token')

    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    event_lists = []
    calendar_list = service.list_calendar_lists.items
    calendar_list.each do |list|
      service.list_events(list.id).items.each do |event|
        event_lists << event
      end
    end
    render json: event_lists
  end
end
