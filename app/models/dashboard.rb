class Dashboard
  def initialize(user)
    @user = user
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
