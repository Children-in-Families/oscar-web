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

      family_ids = user.families.ids
      user.clients.each do |client|
        family_ids << client.family.try(:id)
      end

      can :create, Family
      can :manage, Family, id: family_ids

    elsif user.manager?
      subordinate_users = User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: user.id }).map(&:id)
      subordinate_users << user.id
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: subordinate_users }
      can :manage, Client, id: exited_clients(subordinate_users)
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

      User.where(id: subordinate_users).each do |user|
        user.clients.each do |client|
          family_ids << client.family.try(:id)
        end
      end

      Client.where(id: exited_clients(subordinate_users)).each do |client|
        family_ids << client.family.try(:id)
      end

      user.clients.each do |client|
        family_ids << client.family.try(:id)
      end

      can :create, Family
      can :manage, Family, id: family_ids.compact.uniq
    end
  end

  def exited_clients(users)
    client_ids = []
    users.each do |user|
      PaperTrail::Version.where(item_type: 'CaseWorkerClient', event: 'create').where_object_changes(user_id: user).each do |version|
        next if version.changeset[:user_id].last != user
        client_id = version.changeset[:client_id].last
        next if !Client.find_by(id: client_id).presence.try(:exit_ngo?)
        client_ids << client_id if client_id.present?
      end
    end
    client_ids.uniq
  end
end
