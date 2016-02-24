module ClientsHelper

  def user user
    if can? :manage, :all
      link_to user.name, user_path(user)
    else
      user.name
    end
  end

  def partner partner
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family family
    if can? :manage, :all
      link_to family.name, family_path(family)
    else
      family.name
    end
  end
end
