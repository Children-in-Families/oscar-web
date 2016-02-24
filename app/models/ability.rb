class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    elsif user.case_worker?
      can :manage, Client
      can :manage, Case
    end
  end

end
