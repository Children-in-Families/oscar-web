class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency
    can :manage, ReferralSource
    can :manage, QuarterlyReport
    can :read, ProgramStream
    can :preview, ProgramStream
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

      can :read, :all
      can :version, :all
      can :report, :all
    elsif user.case_worker?
      can :manage, Assessment
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
      can :update, Assessment do |assessment|
        assessment.client.user_id == user.id
      end
      can :create, Task
      can :read, Task
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end

      family_ids = user.families.ids
      user.clients.each do |client|
        family_ids << client.family.try(:id)
      end

      can :create, Family
      can :manage, Family, id: family_ids

    elsif user.manager?
      subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: user.id }).map(&:id)
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: subordinate_users }
      can :manage, Client, id: exited_clients(subordinate_users)
      can :manage, User, id: User.where('manager_ids && ARRAY[?]', user.id).map(&:id)
      can :manage, User, id: user.id
      can :manage, Case
      can :manage, Assessment
      can :manage, CaseNote
      can :manage, Family
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
    end
  end

  def exited_clients(users)
    client_ids = []
    users.each do |user|
      PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').where_object_changes(user_id: user).each do |version|
        client_id = version.changeset[:client_id].last
        next if !Client.find_by(id: client_id).presence.try(:exit_ngo?)
        client_ids << client_id if client_id.present?
      end
    end
    client_ids.uniq
  end
end
