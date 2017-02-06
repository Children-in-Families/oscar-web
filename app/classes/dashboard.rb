class Dashboard
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def client_gender_statistic
    [
      {
        name: I18n.t('classes.dashboard.males'),
        y: male_count,
        active_data: [
          {
            name: I18n.t('classes.dashboard.male_emergency_cares'),
            y: male_ec_count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active EC")
          },
          {
            name: I18n.t('classes.dashboard.male_kinship_cares'),
            y: male_kc_count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active KC")
          },
          {
            name: I18n.t('classes.dashboard.male_foster_cares'),
            y: male_fc_count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active FC")
          }
        ]
      },
      {
        name: I18n.t('classes.dashboard.females'),
        y: female_count,
        active_data: [
         {
           name: I18n.t('classes.dashboard.female_emergency_cares'),
           y: female_ec_count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active EC")
         },
         {
           name: I18n.t('classes.dashboard.female_kinship_cares'),
           y: female_kc_count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active KC")
         },
         {
           name: I18n.t('classes.dashboard.female_foster_cares'),
           y: female_fc_count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active FC")
         }
        ]
      }
    ]
  end

  def client_status_statistic
    able_data = [{ name: 'Able', y: able_count, url: clients_path("client_grid[able_state]": 'Accepted') }]
    if @user.ec_manager?
      [data_by_status.first]
    elsif @user.fc_manager?
      [data_by_status.second]
    elsif @user.kc_manager?
      [data_by_status.last]
    elsif @user.able_manager?
      able_data
    else
      data_by_status
    end
  end

  def family_type_statistic
    [{ name: 'Foster', y: foster_count, url: families_path("family_grid[family_type]": 'foster') },
     { name: 'Kinship', y: kinship_count, url: families_path("family_grid[family_type]": 'kinship') }]
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

  def fc_client
    if @user.admin? || @user.any_case_manager? || @user.visitor?
      Client.active_fc
    elsif @user.case_worker?
      @user.clients.active_fc
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_fc
    end
  end

  def fc_count
    fc_client.count
  end

  def male_fc_count
    fc_client.male.count
  end

  def female_fc_count
    fc_client.female.count
  end

  def kc_client
    if @user.admin? || @user.any_case_manager? || @user.visitor?
      Client.active_kc
    elsif @user.case_worker?
      @user.clients.active_kc
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_kc
    end
  end

  def kc_count
    kc_client.count
  end

  def male_kc_count
    kc_client.male.count
  end

  def female_kc_count
    kc_client.female.count
  end

  def ec_client
    if @user.admin? || @user.any_case_manager? || @user.visitor?
      Client.active_ec
    elsif @user.case_worker?
      @user.clients.active_ec
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_ec
    end
  end

  def ec_count
    ec_client.count
  end

  def male_ec_count
    ec_client.male.count
  end

  def female_ec_count
    ec_client.female.count
  end

  def male_count
    if @user.admin? || @user.visitor?
      Client.all_active_types.male.size
    elsif @user.case_worker?
      @user.clients.all_active_types.male.size
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).all_active_types.male.size
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).all_active_types.male.size
    end
  end

  def female_count
    if @user.admin? || @user.visitor?
      Client.all_active_types.female.size
    elsif @user.case_worker?
      @user.clients.all_active_types.female.size
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).all_active_types.female.size
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).all_active_types.female.count
    end
  end

  def able_count
    if @user.admin? || @user.able_manager? || @user.visitor?
      Client.able.count
    elsif @user.case_worker?
      @user.clients.able.count
    end
  end

  def family_count
    Family.count
  end

  def foster_count
    Family.foster.count
  end

  def kinship_count
    Family.kinship.count
  end

  def staff_count
    User.count
  end

  def partner_count
    Partner.count
  end

  def agency_count
    Agency.count
  end

  def referral_source_count
    ReferralSource.count
  end

  private

  def data_by_status
    [
      { name: I18n.t('classes.dashboard.emergency_cares_html'), y: ec_count, url: clients_path("client_grid[status]": 'Active EC') },
      { name: I18n.t('classes.dashboard.foster_cares_html'), y: fc_count, url: clients_path("client_grid[status]": 'Active FC') },
      { name: I18n.t('classes.dashboard.kinship_cares_html'), y: kc_count, url: clients_path("client_grid[status]": 'Active KC') }
    ]
  end
end
