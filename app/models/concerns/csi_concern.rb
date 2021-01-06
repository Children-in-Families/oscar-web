module CsiConcern
  extend ActiveSupport::Concern

  def eligible_default_csi?
    return true if self.class.name == 'Family'

    return true if date_of_birth.nil?

    client_age = age_as_years
    age        = Setting.first.age || 18
    client_age < age
  end

  def eligible_custom_csi?(custom_assessment_setting)
    return true if self.class.name == 'Family'

    return true if date_of_birth.nil?

    client_age = age_as_years
    age        = custom_assessment_setting.custom_age || 18
    client_age < age
  end

  def age_as_years(date = Date.today)
    ((date - date_of_birth) / 365).to_i
  end

  def age_extra_months(date = Date.today)
    ((date - date_of_birth) % 365 / 31).to_i
  end

  def age
    count_year_from_date('date_of_birth')
  end

  def count_year_from_date(field_date)
    return nil if self.send(field_date).nil?
    date_today = Date.today
    year_count = distance_of_time_in_words_hash(date_today, self.send(field_date)).dig(:years)
    year_count = year_count == 0 ? 'INVALID' : year_count
  end

  def can_create_assessment?(default, value = '')
    latest_assessment = assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: value }).distinct
    return assessments.defaults.count.zero? || assessments.defaults.latest_record.completed? if default

    return (Date.today >= (latest_assessment.latest_record.created_at + assessment_duration('min', false)).to_date) && latest_assessment.latest_record.completed? if latest_assessment.count == 1

    return latest_assessment.latest_record.completed? if latest_assessment.count >= 2

    true
  end

  def next_assessment_date(user_activated_date = nil)
    return Date.today if assessments.defaults.latest_record.blank?

    return nil if user_activated_date.present? && (assessments.defaults.latest_record.present? && assessments.defaults.latest_record.created_at < user_activated_date)

    (assessments.defaults.latest_record.created_at + assessment_duration('max')).to_date
  end

  def custom_next_assessment_date(user_activated_date = nil, custom_assessment_setting_id=nil)
    custom_assessments = []
    custom_assessments = assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: custom_assessment_setting_id }).distinct if custom_assessment_setting_id
    if custom_assessment_setting_id && custom_assessments.present?
      return nil if user_activated_date.present? && custom_assessments.latest_record.created_at < user_activated_date

      (custom_assessments.latest_record&.created_at + assessment_duration('max', false, custom_assessment_setting_id)).to_date
    else
      Date.today
    end
  end
end
