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
    can :manage, ServiceDelivery
    can :manage, CaseConference
    can :manage, InternalReferral

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
      cannot :create, CustomFieldProperty, custom_field: { hidden: true }, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Community'
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can [:read, :create, :update], Partner
      can :manage, Referral
      can :manage, FamilyReferral
      can :create, Task
      can :read, Task
      cannot [:edit, :update], ReferralSource
      cannot :destroy, Client
      can :manage, CarePlan
      can :manage, Enrollment
      can :manage, Community
      can :manage, EnrollmentTracking
      can [:read, :create, :update], ScreeningAssessment

      family_ids = user.families.ids
      family_ids << CaseWorkerFamily.where(user_id: user.id).pluck(:family_id)
      family_ids << FamilyMember.where(client_id: user.clients.ids).pluck(:family_id)
      user.clients.each do |client|
        family_ids << client.current_family_id
      end

      can :create, Family
      can :manage, Family, id: family_ids.flatten.compact.uniq
    elsif user.manager?
      subordinate_user_ids = user.all_subordinates.ids
      subordinate_user_ids << user.id
      exited_client_ids = exited_clients(subordinate_user_ids)
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: subordinate_user_ids }
      can :manage, Client, id: exited_client_ids
      can :manage, User, id: subordinate_user_ids
      can :manage, Case
      can :manage, CaseNote
      can :manage, Partner
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :manage, CustomFieldProperty, custom_formable_type: 'Community'
      can :manage, CustomField
      can :manage, CaseNotes::CustomField
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can :create, Task
      can :read, Task
      can :manage, Referral
      can :manage, FamilyReferral
      can :manage, CarePlan
      can :manage, Enrollment
      can :manage, Community
      can :manage, EnrollmentTracking
      can [:read, :create, :update], ScreeningAssessment

      family_ids = user.families.ids
      family_ids += User.joins(:clients).where(id: subordinate_user_ids).where.not(clients: { current_family_id: nil }).select('clients.current_family_id AS client_current_family_id').map(&:client_current_family_id)
      family_ids += User.joins(:families).where(id: subordinate_user_ids).select('families.id AS family_id').map(&:family_id)
      family_ids += Client.where(id: exited_client_ids).pluck(:current_family_id)
      family_ids += user.clients.pluck(:current_family_id)
      family_ids += FamilyMember.where(client_id: user.clients.ids + exited_client_ids).pluck(:family_id)

      can :create, Family
      can :manage, Family, id: family_ids.compact.uniq
    elsif user.hotline_officer?
      can :manage, Attachment
      can :manage, Case, exited: false
      can :manage, CaseNote
      can :manage, Client
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Community'
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :manage, GovernmentForm
      can [:read, :create, :update], Partner
      can :manage, Referral
      can :manage, FamilyReferral
      can :create, Task
      can :read, Task
      cannot [:edit, :update], ReferralSource
      cannot :destroy, Client
      can :manage, Family
      can [:read, :create, :update], ScreeningAssessment
    end

    cannot :read, Community if Setting.first.hide_community?
    cannot :read, Partner if FieldSetting.hidden_group?('partner')
  end

  def exited_clients(user_ids)
    client_ids = CaseWorkerClient.with_deleted.where(user_id: user_ids).pluck(:client_id)
    Client.where(id: client_ids, status: 'Exited').ids
  end
end
