class CalendarsController < AdminController
  include GoogleCalendarServiceConcern

  def redirect
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
      create_events
      delete_events
      session[:sync] = nil
      if current_user_calendars.present?
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
      create_events
      delete_events
      if current_user_calendars.present?
        redirect_to calendars_path, notice: t('add_event_success')
      else
        redirect_to calendars_path, alert: t('existed_event')
      end
    end
  end
end
