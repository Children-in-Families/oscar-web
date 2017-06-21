class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency
    can :manage, ReferralSource
    can :manage, QuarterlyReport

    if user.admin?
      can :manage, :all
    elsif user.strategic_overviewer?
      cannot :manage, AbleScreeningQuestion
      cannot :manage, Agency
      cannot :manage, ReferralSource
      cannot :manage, QuarterlyReport
      cannot :manage, CustomFieldProperty

      can :read, :all
      can :version, :all
      can :report, :all

      cannot :manage, CaseNote
    elsif user.case_worker?
      can :manage, AbleScreeningQuestion
      can :manage, Assessment
      can :manage, Attachment
      can :manage, Case, exited: false
      can :manage, CaseNote
      can :manage, Client, user_id: user.id
      can :manage, ProgressNote
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.user_id == user.id
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.able_manager?
      can :manage, AbleScreeningQuestion
      can :manage, Assessment
      can :manage, Attachment
      can :manage, CaseNote
      can :manage, Client, able_state: Client::ABLE_STATES
      can :manage, Client, user_id: user.id
      can :manage, ProgressNote
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: "Client"
      can :manage, CustomField
      can :manage, ProgramStream
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.able?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.ec_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active EC'
      can :manage, CaseNote
      can :read, ProgressNote
      can :manage, Family
      can :manage, Partner
      can :manage, Case, { case_type: 'EC', exited: false }
      can :manage, Assessment
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :manage, CustomField
      can :manage, ProgramStream
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.active_ec?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.fc_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active FC'
      can :manage, CaseNote
      can :read, ProgressNote
      can :manage, Family
      can :manage, Partner
      can :manage, Case, { case_type: 'FC', exited: false }
      can :manage, Assessment
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :manage, CustomField
      can :manage, ProgramStream
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.active_fc?
      end
      can :read, ProgressNote
      can :read, Attachment
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.kc_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active KC'
      can :manage, CaseNote
      can :read, ProgressNote
      can :manage, Family
      can :manage, Partner
      can :manage, Case, { case_type: 'KC', exited: false }
      can :manage, Assessment
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :manage, CustomField
      can :manage, ProgramStream
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.active_kc?
      end
      can :read, ProgressNote
      can :read, Attachment
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, user: User.where('manager_ids && ARRAY[?]', user.id)
      can :manage, User, id: User.where('manager_ids && ARRAY[?]', user.id).map(&:id)
      can :manage, Case
      can :manage, Task
      can :manage, Assessment
      can :manage, CaseNote
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomField
      can :manage, ProgramStream
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
    end
  end
end
