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
    session[:referrer] = url_for
    redirect_to redirect_path if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
  end

  def new
    if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
      session[:task_id] = params[:task]
      session[:referrer] = request.referrer
      redirect_to redirect_path
    else
      task      = Task.find(params[:task])
      domain    = Domain.find(task.domain_id)
      summary    = "#{domain.name} - #{task.name}"
      start_date = task.completion_date.to_s
      end_date   = (task.completion_date + 1).to_s
      # events = ''
      client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
                                          client_secret: Rails.application.secrets.google_client_secret,
                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      # validate dulicap task
      # service.list_events('primary').items.each do |event|
      #   if event.summary == summary
      #     events = event.summary
      #     break
      #   end
      # end
      # if events.present?
      #   if params[:client].present?
      #     redirect_to client_tasks_path(params[:client]), alert: t('has_been_added_to_calendar')
      #   else
      #     redirect_to tasks_path, alert: t('has_been_added_to_calendar')
      #   end
      # else
      event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
                                                  end: Google::Apis::CalendarV3::EventDateTime.new(date: end_date),
                                                  summary: summary)
      service.insert_event('primary', event)
      if params[:client].present?
        redirect_to client_tasks_path(params[:client]), notice: t('add_event_success')
      else
        redirect_to tasks_path, notice: t('add_event_success')
      end
      # end
    end
  end

  def all_new
    if session[:authorization].blank? || current_user.expires_at < DateTime.now.in_time_zone
      session[:action] = params[:action]
      session[:referrer] = request.referrer
      redirect_to redirect_path
    else
      tasks = Task.incomplete.of_user(current_user).incomplete.upcoming
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
      if params[:client].present?
        redirect_to client_tasks_path(params[:client]), notice: t('add_event_success')
      else
        redirect_to tasks_path, notice: t('add_event_success')
      end
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
    #// get only cif event
    service.list_events('primary').items.each do |event|
      event_lists << event
    end
    #// get all event
    # calendar_lists = service.list_calendar_lists.items
    # calendar_lists.each do |list|
    #   service.list_events(list.id).items.each do |event|
    #     event_lists << event
    #   end
    # end
    render json: event_lists
  end
end
