class Dashboard
  include Rails.application.routes.url_helpers
  attr_reader :client

  def initialize(user)
    @user = user
    @clients = fetch_client
    @families = Family.all
    @ables = Client.able
    @partners = Partner.all
    @agencies = Agency.all
    @staff    = User.all
    @referral_sources = ReferralSource.all
  end

  def fetch_client
    if @user.admin? || @user.visitor?
      Client.all
    elsif @user.ec_manager?
      ids = @user.clients.ids
      ids += Client.active_ec.ids
      Client.where(id: ids)
    elsif @user.kc_manager?
      ids = @user.clients.ids
      ids += Client.active_kc.ids
      Client..where(id: ids)
    elsif @user.fc_manager?
      ids = @user.clients.ids
      ids += Client.active_fc.ids
      Client.where(id: ids)
    elsif @user.able_manager?
      ids = @user.clients.ids
      ids += Client.able.ids
      Client.where(id: ids)
    elsif @user.case_worker?
      @user.clients
    end
  end

  def client_gender_statistic
    [
      {
        name: I18n.t('classes.dashboard.males'),
        y: @clients.all_active_types.male.count,
        active_data: [
          {
            name: I18n.t('classes.dashboard.male_emergency_cares'),
            y: @clients.active_ec.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active EC")
          },
          {
            name: I18n.t('classes.dashboard.male_kinship_cares'),
            y: @clients.active_kc.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active KC")
          },
          {
            name: I18n.t('classes.dashboard.male_foster_cares'),
            y: @clients.active_fc.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active FC")
          }
        ]
      },
      {
        name: I18n.t('classes.dashboard.females'),
        y: @clients.all_active_types.female.count,
        active_data: [
         {
           name: I18n.t('classes.dashboard.female_emergency_cares'),
           y: @clients.active_ec.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active EC")
         },
         {
           name: I18n.t('classes.dashboard.female_kinship_cares'),
           y: @clients.active_kc.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active KC")
         },
         {
           name: I18n.t('classes.dashboard.female_foster_cares'),
           y: @clients.active_fc.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active FC")
         }
        ]
      }
    ]
  end

  def client_status_statistic
    # if @user.ec_manager?
    #   [data_by_status.first]
    # elsif @user.fc_manager?
    #   [data_by_status.second]
    # elsif @user.kc_manager?
    #   [data_by_status.last]
    # else
    data_by_status
    # end
  end

  def family_type_statistic
    [{ name: 'Foster', y: foster_count, url: families_path("family_grid[family_type]": 'foster') },
     { name: 'Kinship', y: kinship_count, url: families_path("family_grid[family_type]": 'kinship') },
     { name: 'Emergency', y: emergency_count, url: families_path("family_grid[family_type]": 'emergency') }]
  end

  def client_count
    if @user.admin? || @user.visitor?
      Client.count
    elsif @user.case_worker?
      @user.clients.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).count
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).count
    end
  end

  def able_count
    @clients.able.count
  end

  def family_count
    @families.count
  end

  def foster_count
    @families.foster.count
  end

  def kinship_count
    @families.kinship.count
  end

  def emergency_count
    @families.emergency.count
  end

  def staff_count
    @staff.count
  end

  def partner_count
    @partners.count
  end

  def agency_count
    @agencies.count
  end

  def referral_source_count
    @referral_sources.count
  end

  private

  def data_by_status
    [
      { name: I18n.t('classes.dashboard.emergency_cares_html'), y: @clients.active_ec.count, url: clients_path("client_grid[status]": 'Active EC') },
      { name: I18n.t('classes.dashboard.foster_cares_html'), y: @clients.active_fc.count, url: clients_path("client_grid[status]": 'Active FC') },
      { name: I18n.t('classes.dashboard.kinship_cares_html'), y: @clients.active_kc.count, url: clients_path("client_grid[status]": 'Active KC') }
    ]
  end
end
