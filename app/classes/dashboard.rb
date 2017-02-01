class Dashboard
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def client_gender_statistic
    [{ name: I18n.t('classes.dashboard.males'), y: male_count, url: clients_path("client_grid[gender]": 'Male') },
     { name: I18n.t('classes.dashboard.females'), y: female_count, url: clients_path("client_grid[gender]": 'Female') }]
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
    if @user.admin?
      Client.count
    elsif @user.case_worker?
      @user.clients.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).count
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).count
    end
  end

  def fc_count
    if @user.admin? || @user.any_case_manager?
      Client.active_fc.count
    elsif @user.case_worker?
      @user.clients.active_fc.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_fc.count
    end
  end

  def kc_count
    if @user.admin? || @user.any_case_manager?
      Client.active_kc.count
    elsif @user.case_worker?
      @user.clients.active_kc.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_kc.count
    end
  end

  def ec_count
    if @user.admin? || @user.any_case_manager?
      Client.active_ec.count
    elsif @user.case_worker?
      @user.clients.active_ec.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).active_ec.count
    end
  end

  def male_count
    if @user.admin?
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
    if @user.admin?
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
    if @user.admin? || @user.able_manager?
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
