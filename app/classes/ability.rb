class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency
    can :manage, ReferralSource
    can :manage, QuarterlyReport
    can :read, ProgramStream
    can :preview, ProgramStream
    can :manage, Call
    can :manage, Referee

    if user.nil?
      can :manage, Client
    elsif user.admin?
      can :manage, :all
    elsif user.strategic_overviewer?
      cannot :manage, Agency
      cannot :manage, ReferralSource
      cannot :manage, QuarterlyReport
      cannot :manage, CustomFieldProperty
      cannot :manage, CaseNote
      cannot :manage, Call
      cannot :manage, Referee

      can :read, :all
      can :version, :all
      can :report, :all
    elsif user.case_worker?
      can :manage, Attachment
      can :manage, Case, exited: false
      can :manage, CaseNote
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: user.id }
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can [:read, :create, :update], Partner
      can :manage, Referral
      can :create, Task
      can :read, Task
      cannot [:edit, :update], ReferralSource
      cannot :destroy, Client

      family_ids = user.families.ids
      user.clients.each do |client|
        family_ids << client.family.try(:id)
      end

      can :create, Family
      can :manage, Family, id: family_ids

    elsif user.manager?
      subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: user.id }).map(&:id)
      subordinate_users << user.id
      exited_client_ids = exited_clients(subordinate_users)
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: subordinate_users }
      can :manage, Client, id: exited_client_ids
      can :manage, User, id: User.where('manager_ids && ARRAY[?]', user.id).map(&:id)
      can :manage, User, id: user.id
      can :manage, Case
      can :manage, CaseNote
      can :manage, Partner
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :manage, CustomField
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can :create, Task
      can :read, Task
      can :manage, Referral

      family_ids = user.families.ids
      family_ids += User.joins(:clients).where(id: subordinate_users).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      family_ids += Client.where(id: exited_client_ids).pluck(:current_family_id)
      family_ids += user.clients.pluck(:current_family_id)

      can :create, Family
      can :manage, Family, id: family_ids.compact.uniq

    elsif user.hotline_officer?
      can :manage, Attachment
      can :manage, Call
      can :manage, Case, exited: false
      can :manage, CaseNote
      can :manage, Client
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can [:read, :create, :update], Partner
      can :manage, Referral
      can :create, Task
      can :read, Task
      cannot [:edit, :update], ReferralSource
      can :manage, Family
      can :manage, User, id: user.id
    end

    cannot :read, Partner if FieldSetting.hidden_group?('partner')
  end

  def exited_clients(user_ids)
    sql = user_ids.map do |user_id|
      "versions.object_changes ILIKE '%user_id:\n- \n- #{user_id}\n%'"
    end.join(" OR ")
    client_ids = PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').where(sql).map do |version|
      client_id = version.changeset[:client_id].last
    end
    Client.where(id: client_ids, status: 'Exited').ids
  end
end
