class ClientDecorator < Draper::Decorator
  delegate_all

  def care_code
    model.code.present? ? model.code : ''
  end

  def date_of_birth_format
    model.date_of_birth.strftime('%d %B %Y') if model.date_of_birth
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
    Province.find_by_sql("select * from shared.provinces where shared.provinces.id = #{model.birth_province_id} LIMIT 1").first.try(:name) if model.birth_province_id
  end

  def time_in_ngo
    if model.time_in_ngo.present?
      time_in_ngo = model.time_in_ngo
      years = h.t('clients.show.time_in_care_around.year', count: time_in_ngo[:years]) if time_in_ngo[:years] > 0
      months = h.t('clients.show.time_in_care_around.month', count: time_in_ngo[:months]) if time_in_ngo[:months] > 0
      days = h.t('clients.show.time_in_care_around.day', count: time_in_ngo[:days]) if time_in_ngo[:days] > 0
      [years, months, days].join(' ')
    end
  end

  def time_in_cps
    cps_lists = []
    if model.time_in_cps.present?
      model.time_in_cps.each do |cps|
        unless cps[1].blank?
          years  = I18n.t('clients.show.time_in_care_around.year', count: cps[1][:years]) if (cps[1][:years].present? && cps[1][:years] > 0)
          months = I18n.t('clients.show.time_in_care_around.month', count: cps[1][:months]) if (cps[1][:months].present? && cps[1][:months] > 0)
          days   = I18n.t('clients.show.time_in_care_around.day', count: cps[1][:days]) if (cps[1][:days].present? && cps[1][:days] > 0)
          time_in_cps = [years, months,days].join(' ')
          cps_lists << [cps[0], time_in_cps].join(': ')
        end
      end
    end
    cps_lists.join(", ")
  end

  def referral_date
    model.initial_referral_date.strftime('%d %B %Y') if model.initial_referral_date
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
