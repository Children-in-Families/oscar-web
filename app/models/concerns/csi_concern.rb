module CsiConcern
  extend ActiveSupport::Concern
  ONE_WEEK = 1.week
  TWO_WEEKS = 2.weeks

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
    age        = custom_assessment_setting&.custom_age || 18
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

  def can_create_assessment?(default, custom_assessment_setting_id = '')
    latest_assessment = assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: custom_assessment_setting_id }).distinct
    return assessments.defaults.count.zero? || assessments.defaults.latest_record.completed? if default

    assessment_min_max = custom_assessment_setting_id.present? ? assessment_duration('max', false, custom_assessment_setting_id) : assessment_duration('min', false)
    return (Date.today >= (latest_assessment.latest_record.created_at + assessment_min_max).to_date) && latest_assessment.latest_record.completed? if latest_assessment.count == 1
    return latest_assessment.latest_record.completed? if latest_assessment.count >= 2

    true
  end

  def next_case_conference_date(user_activated_date = nil)
    return Date.today if case_conferences.latest_record.blank?

    return nil if user_activated_date.present? && (case_conferences.latest_record.present? && case_conferences.latest_record.meeting_date < user_activated_date)

    (case_conferences.latest_record.meeting_date + assessment_duration('max')).to_date
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
    elsif self.class.name == 'Family'
      return nil if user_activated_date.present? && assessments.customs.latest_record.created_at < user_activated_date

      (assessments.customs.latest_record&.created_at + assessment_duration('max', false, custom_assessment_setting_id)).to_date
    else
      Date.today
    end
  end

  def assessment_duration(duration, default = true, custom_assessment_setting_id=nil)
    if duration == 'max'
      setting = Setting.first
      if default || self.class.name == 'Family'
        assessment_period    = setting.max_assessment
        assessment_frequency = setting.assessment_frequency
      else
        if custom_assessment_setting_id.present?
          custom_assessment_setting = CustomAssessmentSetting.find(custom_assessment_setting_id)
          assessment_period    = custom_assessment_setting.max_custom_assessment
          assessment_frequency = custom_assessment_setting.custom_assessment_frequency
        else
          assessment_period    = setting.max_custom_assessment
          assessment_frequency = setting.custom_assessment_frequency
        end
      end
    else
      assessment_period = 3
      assessment_frequency = 'month'
    end

    assessment_period.send(assessment_frequency)
  end

  def active_young_clients(clients)
    clients.joins(:assessments).active_accepted_status.where("(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, current_date))) :: int) < ?", current_setting.age || 18)
  end

  def clients_have_recent_default_assessments(clients)
    clients_recent_assessment_dates = clients.merge(Assessment.defaults.most_recents).select("clients.id, assessments.created_at AS assessment_created_at")
    client_ids = collect_clients_have_recent_assessment_dates(clients_recent_assessment_dates) if current_setting.try(:enable_default_assessment?)
    clients.where(id: client_ids).uniq
  end

  def clients_have_recent_custom_assessments(clients)
    clients_recent_custom_assessment_dates = clients.merge(Assessment.customs.most_recents.joins(:domains).where(domains: { custom_assessment_setting_id: CustomAssessmentSetting.all.ids })).uniq("client.ids, assessment_created_at AS assessment_created_at")
    client_ids = collect_clients_have_recent_assessment_dates(clients_recent_custom_assessment_dates) if current_setting.try(:any_custom_assessment_enable?)
    clients.where(id: client_ids).uniq
  end

  def collect_clients_have_recent_assessment_dates(client_ids_recent_assessment_dates)
    max_assessment_duration = current_setting.max_assessment_duration
    client_ids_recent_assessment_dates.map {|obj| [obj.id, obj.assessment_created_at] }.map do |client_id, recent_assessment_date|
      next_assessment_date = recent_assessment_date + max_assessment_duration
      repeat_notifications = current_setting.two_weeks_assessment_reminder? ? [(next_assessment_date - TWO_WEEKS), (next_assessment_date - ONE_WEEK)] : [next_assessment_date - ONE_WEEK]
      client_id if repeat_notifications.include?(Date.today)
    end.compact
  end

end
