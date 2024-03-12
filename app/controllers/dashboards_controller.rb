class DashboardsController < AdminController
  include CsiConcern

  before_action :task_of_user, :find_overdue_task_params, :find_tasks, only: [:index]
  skip_before_action :notify_user, :set_sidebar_basic_info, only: [:notification, :family_tab, :side_menu_data]

  def index
    @program_streams = ProgramStream.includes(:program_stream_services, :services).where(program_stream_services: { service_id: nil }).attached_with('Client')
    @dashboard = Dashboard.new(Client.accessible_by(current_ability))
    @referral_sources = ReferralSource.child_referrals.where(ancestry: nil)
    @select_client_options = Client.accessible_by(current_ability).active_accepted_status
    @custom_domains = Domain.custom_csi_domains
    @custom_assessment_settings = CustomAssessmentSetting.includes(:domains).where(enable_custom_assessment: true)

    @date_validation_error = fetch_data_logic_error
  end

  def update_program_stream_service
    programs = params.require(:program_streams)
    programs.each do |program|
      program_stream = ProgramStream.find(program.first)
      next if program.last['service_ids'].nil?
      program_stream.update(service_ids: program.last['service_ids'].uniq)
    end
  end

  def client_data_validation
    @date_validation_error = fetch_data_logic_error
    clients = Client.accessible_by(current_ability).where(id: @date_validation_error[:ids]).page(params[:page]).per(15)
    @client_grid = ClientGrid.new({ column_names: [:id, :slug, :given_name, :family_name, :local_given_name, :local_family_name, :status, :gender] }).scope { clients }
  end

  def family_tab
    @dashboard = Dashboard.new(Client.none, family_only: true)

    render json: { data: render_to_string(partial: 'family') }
  end

  def notification
    clients = Client.accessible_by(current_ability).non_exited_ngo
    @notification = UserNotification.new(current_user, clients)
  end

  def side_menu_data
    @client_count = Client.accessible_by(current_ability).count
    @family_count = Family.accessible_by(current_ability).count
    @community_count = Community.accessible_by(current_ability).count
    @user_count = User.where(deleted_at: nil).accessible_by(current_ability).count
    @partner_count = Partner.count
    @agency_count = Agency.count
    @calls_count = Call.count
    @referees_count = Referee.count
    @referral_source_count = ReferralSource.count
    @archived_count = Client.only_deleted.accessible_by(current_ability).count
  end

  def notify_task
    respond_to do |format|
      format.js do
      end
    end
  end

  private

  def find_overdue_task_params
    @default_params = params[:assessments].nil? && params[:forms].nil? && params[:tasks].nil?
    @assessment_params = params[:assessments].presence == 'true' || current_user.case_worker?
    @form_params = params[:forms].presence == 'true' || current_user.case_worker?
    @task_params = params[:tasks].presence == 'true' || current_user.case_worker?
  end

  def task_of_user
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def find_tasks
    @clients = find_clients
    @users = find_users&.order(:first_name, :last_name) || [] unless current_user.case_worker?
  end

  def find_users
    User.self_and_subordinates(current_user)
  end

  def find_clients
    clients = []
    @setting = Setting.cache_first
    user_ability = Ability.new(@user)
    accepted_clients = Client.accessible_by(user_ability).active_accepted_status.distinct
    eligible_clients = active_young_clients(accepted_clients, @setting)
    eligible_clients.each do |client|
      overdue_tasks = []
      today_tasks = []
      upcoming_tasks = []
      overdue_trackings = []
      today_trackings = []
      upcoming_trackings = []
      overdue_forms = []
      today_forms = []
      upcoming_forms = []
      if @task_params && @user.activated_at.present?
        overdue_tasks << client.tasks.where('tasks.created_at > ?', @user.activated_at).incomplete.exclude_exited_ngo_clients.of_user(@user).overdue_incomplete
        today_tasks << client.tasks.where('tasks.created_at > ?', @user.activated_at).incomplete.exclude_exited_ngo_clients.of_user(@user).today_incomplete
        upcoming_tasks << client.tasks.where('tasks.created_at > ?', @user.activated_at).incomplete.exclude_exited_ngo_clients.of_user(@user).upcoming_within_three_months
      elsif @task_params
        overdue_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).overdue_incomplete
        today_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).today_incomplete
        upcoming_tasks << client.tasks.incomplete.exclude_exited_ngo_clients.of_user(@user).upcoming_within_three_months
      end

      if @form_params
        custom_fields = client.custom_fields.where.not(frequency: '')
        custom_fields.each do |custom_field|
          next_custom_field_date = client.next_custom_field_date(client, custom_field)
          if next_custom_field_date < Date.today
            overdue_forms << [custom_field, next_custom_field_date]
          elsif next_custom_field_date == Date.today
            today_forms << [custom_field, next_custom_field_date]
          elsif next_custom_field_date.between?(Date.tomorrow, 3.months.from_now)
            upcoming_forms << [custom_field, next_custom_field_date]
          end
        end

        client_active_enrollments = client.client_enrollments.active
        client_active_enrollments.each do |client_active_enrollment|
          trackings = client_active_enrollment.trackings.where.not(frequency: '')
          trackings.each do |tracking|
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            next_client_enrollment_tracking_date = client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking)
            if next_client_enrollment_tracking_date < Date.today
              overdue_trackings << [tracking, next_client_enrollment_tracking_date]
            elsif next_client_enrollment_tracking_date == Date.today
              today_trackings << [tracking, next_client_enrollment_tracking_date]
            elsif next_client_enrollment_tracking_date.between?(Date.tomorrow, 3.months.from_now)
              upcoming_trackings << [tracking, next_client_enrollment_tracking_date]
            end
          end
        end
      end

      clients << [client, { overdue_forms: overdue_forms.uniq, today_forms: today_forms.uniq, upcoming_forms: upcoming_forms.uniq,
                           overdue_trackings: overdue_trackings.uniq, today_trackings: today_trackings.uniq,
                           upcoming_trackings: upcoming_trackings.uniq, overdue_tasks: overdue_tasks.flatten.uniq,
                           today_tasks: today_tasks.flatten.uniq, upcoming_tasks: upcoming_tasks.flatten.uniq }]
    end
    clients
  end

  def fetch_data_logic_error
    sql = <<-SQL.squish
      LEFT OUTER JOIN enter_ngos ON enter_ngos.client_id = clients.id
      LEFT OUTER JOIN client_enrollments ON client_enrollments.client_id = clients.id
      LEFT OUTER JOIN exit_ngos ON exit_ngos.client_id = clients.id
    SQL

    sub_sql_min_max = <<-SQL.squish
      (MIN(client_enrollments.enrollment_date) < MIN(enter_ngos.accepted_date) AND MAX(client_enrollments.enrollment_date) < MAX(enter_ngos.accepted_date)) OR
      (MIN(exit_ngos.exit_date) < MIN(client_enrollments.enrollment_date) AND MAX(exit_ngos.exit_date) < MAX(client_enrollments.enrollment_date)) OR
      (MIN(exit_ngos.exit_date) < MIN(enter_ngos.accepted_date) AND MAX(exit_ngos.exit_date) < MAX(enter_ngos.accepted_date))
    SQL

    if current_user.case_worker? || current_user.manager?
      # sql += ' LEFT OUTER JOIN case_worker_clients ON case_worker_clients.client_id = clients.id'
      clients_error = Client.accessible_by(current_ability).joins(sql).group('clients.id, case_worker_clients.id').having(sub_sql_min_max)
    else
      clients_error = Client.accessible_by(current_ability).joins(sql).group('clients.id').having(sub_sql_min_max)
    end

    { ids: clients_error.ids, count: clients_error.to_a.count }
  end
end
