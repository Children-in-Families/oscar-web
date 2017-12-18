class DashboardsController < AdminController
  before_action :find_tasks, only: [:index]

  def index
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
  end

  private

  def find_tasks
    if params[:overdue_forms].presence == 'true' && params[:overdue_assessments].presence == 'true'
      client_ids = overdue_forms & overdue_assessments
    elsif params[:overdue_forms].presence == 'true'
      client_ids = overdue_forms
    elsif params[:overdue_assessments].presence == 'true'
      client_ids = overdue_assessments
    end

    if params[:overdue_forms].presence == 'true' || params[:overdue_assessments].presence == 'true'
      @tasks = Task.incomplete.exclude_exited_ngo_clients.of_user(task_of_user).where(client: client_ids).uniq
    else
      @tasks = Task.incomplete.exclude_exited_ngo_clients.of_user(task_of_user).uniq
    end

    @tasks = @tasks.overdue if params[:overdue_tasks].presence == 'true'
    @users = find_users.order(:first_name, :last_name) unless current_user.case_worker?
  end

  def find_users
    User.self_and_subordinates(current_user)
  end

  def task_of_user
    params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def overdue_forms
    client_enrollment_tracking_overdue = task_of_user.client_enrollment_tracking_overdue_or_due_today[:clients_overdue].map(&:id)
    (custom_field_overdue + client_enrollment_tracking_overdue).uniq
  end

  def overdue_assessments
    ids = []
    task_of_user.clients.joins(:assessments).all_active_types.each do |client|
      ids << client.id if client.next_assessment_date < Date.today
    end
    ids
  end

  def custom_field_overdue
    user = task_of_user
    clients = user.clients
    overdue_client_ids = []
    clients.each do |client|
      client.custom_fields.uniq.each do |custom_field|
        if next_custom_field_date(client, custom_field) < Date.today
          overdue_client_ids << client.id
        end
      end
    end
    overdue_client_ids.uniq
  end

  def next_custom_field_date(entity, custom_field)
    (entity.custom_field_properties.by_custom_field(custom_field).last.created_at.to_date) + custom_field_frequency(custom_field)
  end

  def custom_field_frequency(custom_field)
    frequency         = custom_field.frequency
    time_of_frequency = custom_field.time_of_frequency
    case frequency
    when 'Daily'   then time_of_frequency.day
    when 'Weekly'  then time_of_frequency.week
    when 'Monthly' then time_of_frequency.month
    when 'Yearly'  then time_of_frequency.year
    else 0.day
    end
  end
end
