class CalendarsController < AdminController
  def redirect
    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    })
    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      redirect_uri: callback_url,
      code: params[:code]
    })
    response = client.fetch_access_token!
    session[:authorization] = response
    redirect_to calendars_path
  end

  def index
  end

  # def new
  #   if params[:summary].present?
  #     primary_calendar_id = ''
  #     client = Signet::OAuth2::Client.new({
  #       client_id: Rails.application.secrets.google_client_id,
  #       client_secret: Rails.application.secrets.google_client_secret,
  #       token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
  #     })
  #
  #     client.update!(session[:authorization])
  #
  #     service = Google::Apis::CalendarV3::CalendarService.new
  #     service.authorization = client
  #     event = Google::Apis::CalendarV3::Event.new({
  #       start: Google::Apis::CalendarV3::EventDateTime.new(date: params[:start_date]),
  #       end: Google::Apis::CalendarV3::EventDateTime.new(date: params[:end_date]),
  #       summary: params[:summary]
  #     })
  #     calendars = service.list_calendar_lists.items
  #     calendars.each do |calendar|
  #       primary_calendar_id = calendar.id if calendar.primary == true
  #     end
  #     service.insert_event(primary_calendar_id, event)
  #
  #     redirect_to calendar_path
  #   end
  # end

  def find_event
    client = Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    })

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
