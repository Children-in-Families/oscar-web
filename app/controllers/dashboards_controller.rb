class DashboardsController < AdminController
  before_action :task_of_user, :find_overhaul_task_params, :find_tasks, only: [:index]

  def index
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
  end

  private

  def find_overhaul_task_params
    @default_params    = params[:assessments].nil? && params[:forms].nil? && params[:tasks].nil?
    @assessment_params = params[:assessments].presence == 'true' || current_user.case_worker?
    @form_params       = params[:forms].presence == 'true' || current_user.case_worker?
    @task_params       = params[:tasks].presence == 'true' || current_user.case_worker?
  end

  def task_of_user
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def find_tasks
    @clients = find_clients
    @users = find_users.order(:first_name, :last_name) unless current_user.case_worker?
  end

  def find_users
    User.self_and_subordinates(current_user)
  end

  def find_clients
    clients_overdue = []
    clients_duetoday = []
    clients_upcoming = []
    clients = []
    Client.active_accepted_status.each do |client|
      overdue_tasks = []
      today_tasks = []
      upcoming_tasks = []
      overdue_trackings = []
      today_trackings = []
      upcoming_trackings = []
      overdue_forms = []
      today_forms = []
      upcoming_forms = []
      if @task_params
        overdue_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).overdue_incomplete
        today_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).today_incomplete
        upcoming_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).upcoming_within_three_months
      end

      if @form_params && client.user_ids.include?(@user.id)
        custom_fields = client.custom_fields.where.not(frequency: '')
        custom_fields.each do |custom_field|
          if client.next_custom_field_date(client, custom_field) < Date.today
            overdue_forms << custom_field
          elsif client.next_custom_field_date(client, custom_field) == Date.today
            today_forms << custom_field
          elsif client.next_custom_field_date(client, custom_field).between?(Date.tomorrow, 3.months.from_now)
            upcoming_forms << custom_field
          end
        end

        client_active_enrollments = client.client_enrollments.active
        client_active_enrollments.each do |client_active_enrollment|
          trackings = client_active_enrollment.trackings.where.not(frequency: '')
          trackings.each do |tracking|
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
              overdue_trackings << tracking
            elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) == Date.today
              today_trackings << tracking
            elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking).between?(Date.tomorrow, 3.months.from_now)
              upcoming_trackings << tracking
            end
          end
        end
      end
      clients << [client, { overdue_forms: overdue_forms.uniq, today_forms: today_forms.uniq, upcoming_forms: upcoming_forms.uniq, overdue_trackings: overdue_trackings.uniq, today_trackings: today_trackings.uniq, upcoming_trackings: upcoming_trackings.uniq,
        overdue_tasks: overdue_tasks.flatten.uniq, today_tasks: today_tasks.flatten.uniq, upcoming_tasks: upcoming_tasks.flatten.uniq }]
    end
    clients
  end
end
