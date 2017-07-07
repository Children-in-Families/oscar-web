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
      session[:task_id] = nil
      session[:action] = nil
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
      calendars = current_user.calendars.sync_status_false
      calendars.each do |event_list|
        event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.start_date.to_date.to_s),
                                                    end: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.end_date.to_date.to_s),
                                                    summary: event_list.title)
        service.insert_event('primary', event)
        event_list.update(sync_status: true)
      end
      message = calendars.present? ? t('add_event_success') : t('existed_event')
      redirect_to calendars_path, notice: message
    end
  end
end
