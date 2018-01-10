class CalendarsController < AdminController
  def redirect
    # url =  callback_url.gsub(/country.*\&/i, '')
    # url =  callback_url.gsub(/[?]country.*\&locale.*/i, '')
    url = callback_url.gsub(/\?.*/, '')
    client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                        client_secret: Rails.application.secrets.google_client_secret,
                                        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                        scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
                                        redirect_uri: url)
    redirect_to client.authorization_uri.to_s
  end

  def callback
    if params[:error].present?
      session[:sync] = nil
      redirect_to calendars_path
    else
      # url =  callback_url.gsub(/country.*\&/i, '')
      # url =  callback_url.gsub(/[?]country.*\&locale.*/i, '')
      url = callback_url.gsub(/\?.*/, '')
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                          redirect_uri: url,
                                          code: params[:code])
      response = client.fetch_access_token!
      current_user.update(expires_at: DateTime.now + response['expires_in'].seconds)
      session[:authorization] = response
      redirect_to calendars_path
    end
  end

  def index
    if session[:sync] == 'connected'
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
      session[:sync] = nil
      if calendars.present?
        redirect_to calendars_path, notice: t('add_event_success')
      else
        redirect_to calendars_path, alert: t('existed_event')
      end
    end
  end

  def sync
    if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
      session[:sync] = 'connected'
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
      if calendars.present?
        redirect_to calendars_path, notice: t('add_event_success')
      else
        redirect_to calendars_path, alert: t('existed_event')
      end
    end
  end
end
