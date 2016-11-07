class Dashboard
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def client_url(status)
    clients_path(status)
  end

  def family_url(status)
    families_path(status)
  end

  def client_gender_statistic
    [{ name: I18n.t('classes.dashboard.males'), y: male_count, url: client_url("client_grid[gender]":"Male") },
     { name: I18n.t('classes.dashboard.females'), y: female_count, url: client_url("client_grid[gender]":"Female") }]
  end

  def client_status_statistic
    [{ name: I18n.t('classes.dashboard.emergency_cares_html'), y: ec_count, url: client_url("client_grid[status]":"Active EC") },
     { name: I18n.t('classes.dashboard.foster_cares_html'), y: fc_count, url: client_url("client_grid[status]":"Active FC") },
     { name: I18n.t('classes.dashboard.kinship_cares_html'), y: kc_count, url: client_url("client_grid[status]":"Active KC") }]
  end

  def family_type_statistic
    [{ name: 'Foster', y: foster_count, url: family_url("family_grid[family_type]":"foster") },
     { name: 'kinship', y: kinship_count, url: family_url("family_grid[family_type]":"kinship") }]
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
      Client.in_any_able_states_managed_by.active_fc.count
    end
  end

  def kc_count
    if @user.admin? || @user.any_case_manager?
      Client.active_kc.count
    elsif @user.case_worker?
      @user.clients.active_kc.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by.active_kc.count
    end
  end

  def ec_count
    if @user.admin? || @user.any_case_manager?
      Client.active_ec.count
    elsif @user.case_worker?
      @user.clients.active_ec.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by.active_ec.count
    end
  end

  def male_count
    if @user.admin?
      Client.male.count
    elsif @user.case_worker?
      @user.clients.male.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).male.count
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).male.count
    end
  end

  def female_count
    if @user.admin?
      Client.female.count
    elsif @user.case_worker?
      @user.clients.female.count
    elsif @user.able_manager?
      Client.in_any_able_states_managed_by(@user).female.count
    elsif @user.any_case_manager?
      Client.managed_by(@user, @user.client_status).female.count
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
end
