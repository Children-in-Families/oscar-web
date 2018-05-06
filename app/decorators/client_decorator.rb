class ClientDecorator < Draper::Decorator
  delegate_all

  def care_code
    model.code.present? ? model.code : ''
  end

  def date_of_birth_format
    model.date_of_birth.strftime('%B %d, %Y') if model.date_of_birth
  end

  def age
    if model.date_of_birth
      year = h.pluralize(model.age_as_years, 'year')
      month = h.pluralize(model.age_extra_months, 'month')
    end
    h.safe_join([year, " #{month}"])
  end

  def current_province
    model.province.name if province
  end

  def birth_province
    model.birth_province.name if model.birth_province
  end

  def time_in_care
    h.t('.time_in_care_around', count: model.time_in_care) if model.time_in_care
  end

  def referral_date
    model.initial_referral_date.strftime('%B %d, %Y') if model.initial_referral_date
  end

  def referral_source
    model.referral_source.name if model.referral_source
  end

  def received_by
    model.received_by if model.received_by
  end

  def follow_up_by
    model.followed_up_by if model.followed_up_by
  end

  private

  def can_add_ec?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end

  def can_add_fc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end

  def can_add_kc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end
end
