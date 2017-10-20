class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency
    can :manage, ReferralSource
    can :manage, QuarterlyReport
    can :read, ProgramStream, id: ProgramStreamPermission.where(readable: true, user_id: user.id).pluck(:program_stream_id)
    can :preview, ProgramStream
    can :update, ProgramStream, id: ProgramStreamPermission.where(editable: true, user_id: user.id).pluck(:program_stream_id)

    if user.admin?
      can :manage, :all
    elsif user.strategic_overviewer?
      cannot :manage, AbleScreeningQuestion
      cannot :manage, Agency
      cannot :manage, ReferralSource
      cannot :manage, QuarterlyReport
      cannot :manage, CustomFieldProperty
      cannot :manage, CaseNote
      cannot :update, ProgramStream

      can :read, :all
      can :version, :all
      can :report, :all

    elsif user.case_worker?
      can :manage, AbleScreeningQuestion
      can :manage, Assessment
      can :manage, Attachment
      can :manage, Case, exited: false
      can :manage, CaseNote
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: user.id }
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
      can :create, Client
      can :manage, Client, able_state: Client::ABLE_STATES
      can :manage, Client, case_worker_clients: { user_id: user.id }
      can :manage, ProgressNote
      can :manage, Task
      can :manage, CustomFieldProperty, custom_formable_type: "Client"
      can :create, CustomField
      can :read, CustomField, id: CustomFieldPermission.where(readable: true, user_id: user.id).pluck(:custom_field_id)
      can :preview, CustomField
      can :update, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :destroy, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
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
      can :create, Client
      can :manage, Client, status: 'Active EC'
      can :manage, Client, case_worker_clients: { user_id: user.id }
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
      can :create, CustomField
      can :read, CustomField, id: CustomFieldPermission.where(readable: true, user_id: user.id).pluck(:custom_field_id)
      can :preview, CustomField
      can :update, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :destroy, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
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
      can :create, Client
      can :manage, Client, status: 'Active FC'
      can :manage, Client, case_worker_clients: { user_id: user.id }
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
      can :create, CustomField
      can :read, CustomField, id: CustomFieldPermission.where(readable: true, user_id: user.id).pluck(:custom_field_id)
      can :preview, CustomField
      can :update, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :destroy, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.active_fc?
      end
      can :read, Attachment
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.kc_manager?
      can :create, Client
      can :manage, Client, status: 'Active KC'
      can :manage, Client, case_worker_clients: { user_id: user.id }
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
      can :create, CustomField
      can :read, CustomField, id: CustomFieldPermission.where(readable: true, user_id: user.id).pluck(:custom_field_id)
      can :preview, CustomField
      can :update, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :destroy, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :update, Assessment do |assessment|
        assessment.client.active_kc?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
      can :read, Attachment
    elsif user.manager?
      can :manage, AbleScreeningQuestion
      can :create, Client
      can :manage, Client, case_worker_clients: { user_id: User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: user.id }).map(&:id) }
      can :manage, User, id: User.where('manager_ids && ARRAY[?]', user.id).map(&:id)
      can :manage, User, id: user.id
      can :manage, Case
      can :manage, Task
      can :manage, Assessment
      can :manage, CaseNote
      can :manage, Family
      can :manage, Partner
      can :manage, CustomFieldProperty, custom_formable_type: 'Client'
      can :manage, CustomFieldProperty, custom_formable_type: 'Family'
      can :manage, CustomFieldProperty, custom_formable_type: 'Partner'
      can :create, CustomField
      can :read, CustomField, id: CustomFieldPermission.where(readable: true, user_id: user.id).pluck(:custom_field_id)
      can :preview, CustomField
      can :update, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :destroy, CustomField, id: CustomFieldPermission.where(editable: true, user_id: user.id).pluck(:custom_field_id)
      can :manage, ClientEnrollment
      can :manage, ClientEnrollmentTracking
      can :manage, LeaveProgram
      can :read, ProgressNote
    end
  end
end
