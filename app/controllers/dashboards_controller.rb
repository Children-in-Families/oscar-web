class DashboardsController < AdminController
  before_action :task_of_user, :find_tasks, only: [:index]

  def index
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
  end

  private

  def task_of_user
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def find_tasks
    client_ids = find_clients

    if params[:overdue_forms].presence == 'true' || params[:overdue_assessments].presence == 'true'
      @tasks = Task.incomplete.exclude_exited_ngo_clients.of_user(@user).where(client: client_ids).uniq
    else
      @tasks = Task.incomplete.exclude_exited_ngo_clients.of_user(@user).uniq
    end

    @tasks = @tasks.overdue if params[:overdue_tasks].presence == 'true'
    @users = find_users.order(:first_name, :last_name) unless current_user.case_worker?
  end

  def find_users
    User.self_and_subordinates(current_user)
  end

  def find_clients
    if params[:overdue_forms].presence == 'true' && params[:overdue_assessments].presence == 'true'
      overdue_forms & overdue_assessments
    elsif params[:overdue_forms].presence == 'true'
      overdue_forms
    elsif params[:overdue_assessments].presence == 'true'
      overdue_assessments
    end
  end

  def overdue_forms
    client_enrollment_tracking_overdue = @user.client_enrollment_tracking_overdue_or_due_today[:clients_overdue].map(&:id)
    (custom_field_overdue + client_enrollment_tracking_overdue).uniq
  end

  def overdue_assessments
    ids = []
    @user.clients.joins(:assessments).all_active_types.each do |client|
      ids << client.id if client.next_assessment_date < Date.today
    end
    ids
  end

  def custom_field_overdue
    overdue_client_ids = []
    clients = @user.clients.joins(:custom_fields).where.not(custom_fields: { frequency: '' })
    clients.each do |client|
      client.custom_fields.each do |custom_field|
        overdue_client_ids << client.id if client.next_custom_field_date(client, custom_field) < Date.today
      end
    end
    overdue_client_ids.uniq
  end
end
