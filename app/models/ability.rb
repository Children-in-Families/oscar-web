class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :read, :update, :destroy, to: :rud

    can :manage, Agency
    can :manage, ReferralSource

    can :manage, QuarterlyReport

    if user.admin?
      can :manage, :all
    elsif user.case_worker?
      can :manage, Client, user_id: user.id
      can :manage, Case
      can :manage, Assessment
      can :manage, Survey
      can :update, Assessment do |assessment|
        assessment.client.user_id == user.id
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.able_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, able: true
      can :manage, Assessment
      can :manage, Survey
      can :update, Assessment do |assessment|
        assessment.client.able?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.ec_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active EC'
      can :manage, Family
      can :manage, Partner
      can :manage, Case, case_type: 'EC'
      can :manage, Assessment
      can :manage, Survey
      can :update, Assessment do |assessment|
        assessment.client.active_ec?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.fc_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active FC'
      can :manage, Family
      can :manage, Partner
      can :manage, Case, case_type: 'FC'
      can :manage, Assessment
      can :manage, Survey
      can :update, Assessment do |assessment|
        assessment.client.active_fc?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    elsif user.kc_manager?
      can :manage, Client, user_id: user.id
      can :manage, Client, status: 'Active KC'
      can :manage, Family
      can :manage, Partner
      can :manage, Case, case_type: 'KC'
      can :manage, Assessment
      can :manage, Survey
      can :update, Assessment do |assessment|
        assessment.client.active_kc?
      end
      cannot :update, Assessment do |assessment|
        Date.current > assessment.created_at + 2.weeks
      end
    end
  end
end
