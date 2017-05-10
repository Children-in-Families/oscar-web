class TasksController < AdminController
  load_and_authorize_resource

  def index
    @tasks = Task.incomplete.of_user(task_of_user)
    @users = find_users.order(:first_name, :last_name)
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

  private

  def find_users
    if current_user.admin? || current_user.strategic_overviewer?
      User.all
    elsif current_user.manager?
      User.where('id = ? OR manager_id = ?', current_user.id, current_user.id)
    else
      User.in_department(current_user.department_id)
    end
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end
end
