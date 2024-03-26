module CsiConcern
  extend ActiveSupport::Concern
  ONE_WEEK = 1.week
  TWO_WEEKS = 2.weeks

  def eligible_default_csi?
    return true if self.class.name == 'Family'

    return true if date_of_birth.nil?

    client_age = age_as_years
    age = Setting.first.age || 18
    client_age < age
  end

  def eligible_custom_csi?(custom_assessment_setting)
    return true if self.class.name == 'Family'

    return true if date_of_birth.nil?

    client_age = age_as_years
    age = custom_assessment_setting&.custom_age || 18
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
    return assessments.defaults.count.zero? || assessments.defaults.latest_record.completed? if default

    if custom_assessment_setting_id.present?
      latest_assessment = assessments.customs.joins(:domains).where(domains: { custom_assessment_setting_id: custom_assessment_setting_id }).distinct
    else
      latest_assessment = assessments.customs.joins(:domains).distinct
    end

    assessment_min_max = custom_assessment_setting_id.present? ? assessment_duration('max', false, custom_assessment_setting_id) : assessment_duration('min', false)
    return (Date.today >= (latest_assessment.latest_record.created_at + assessment_min_max).to_date) && latest_assessment.latest_record.completed? if latest_assessment.count >= 1

    # return latest_assessment.latest_record.completed? if latest_assessment.count >= 2

    true
  end

  def next_case_conference_date(user_activated_date = nil)
    return Date.today if case_conferences.latest_record.blank?

    return nil if user_activated_date.present? && (case_conferences.latest_record.present? && case_conferences.latest_record.meeting_date < user_activated_date)

    (case_conferences.latest_record.meeting_date + assessment_duration('max')).to_date
  end

  def next_assessment_date(user_activated_date = nil)
    last_record = default_most_recents_assessments.to_a.first

    return Date.today if last_record.blank?

    return nil if user_activated_date.present? && (last_record.present? && last_record.created_at < user_activated_date)

    (last_record.created_at + assessment_duration('max')).to_date
  end

  # Use method name next_assessment_date2 to avoid conflict with custom_next_assessment_date
  # This method was refactored from helper to avoid N+1
  # To be used only on Client model
  def next_custom_assessment_date(only_enable_custom_assessment, user_activated_date)
    return @client_custom_next_assessment_date if @client_custom_next_assessment_date.present?

    ids = custom_assessment_domains.map(&:custom_assessment_setting_id).flatten.uniq

    @client_custom_next_assessment_date = only_enable_custom_assessment.select { |eca| eca.id.in?(ids) }.map do |custom_assessment|
      next if eligible_custom_csi?(custom_assessment)

      custom_next_assessment_date(user_activated_date, custom_assessment&.id)
    end.compact
  end

  def custom_next_assessment_date(user_activated_date = nil, custom_assessment_setting_id = nil)
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

  def assessment_duration(duration, default = true, custom_assessment_setting_id = nil)
    if duration == 'max'
      setting = Setting.first
      if custom_assessment_setting_id.present?
        custom_assessment_setting = CustomAssessmentSetting.find(custom_assessment_setting_id)
        assessment_period = custom_assessment_setting.max_custom_assessment
        assessment_frequency = custom_assessment_setting.custom_assessment_frequency
      elsif default || self.class.name == 'Family'
        assessment_period = setting.max_assessment
        assessment_frequency = setting.assessment_frequency
      else
        assessment_period = setting.max_custom_assessment
        assessment_frequency = setting.custom_assessment_frequency
      end
    else
      assessment_period = 3
      assessment_frequency = 'month'
    end

    return 0.day if assessment_frequency == 'unlimited'

    assessment_period.send(assessment_frequency)
  end

  def active_young_clients(clients, setting = nil)
    clients.active_accepted_status.where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, current_date))) :: int) < ?', (setting || current_setting).age || 18)
  end

  def clients_have_recent_default_assessments(clients)
    sql = 'clients.id, (SELECT assessments.created_at FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = true ORDER BY assessments.created_at DESC LIMIT 1) AS assessment_created_at'
    clients_recent_assessment_dates = Client.joins(:assessments).where(id: clients.ids).merge(Assessment.defaults.most_recents).select(sql)
    client_ids = collect_clients_have_recent_assessment_dates(clients_recent_assessment_dates) if current_setting.try(:enable_default_assessment?)
    clients.where(id: client_ids).uniq
  end

  def clients_have_recent_custom_assessments(clients)
    sql = 'clients.id, (SELECT assessments.created_at FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = false ORDER BY assessments.created_at DESC LIMIT 1) AS assessment_created_at'
    client_ids = []
    CustomAssessmentSetting.only_enable_custom_assessment.each do |custom_assessment_setting|
      clients_recent_custom_assessment_dates = Client.joins(:assessments).where(id: clients.ids).merge(Assessment.customs.most_recents.joins(:domains).where(domains: { custom_assessment_setting_id: CustomAssessmentSetting.only_enable_custom_assessment.ids })).select(sql)
      client_ids << collect_clients_have_recent_custom_assessment_dates(clients_recent_custom_assessment_dates, custom_assessment_setting) if current_setting.try(:any_custom_assessment_enable?)
    end
    clients.where(id: client_ids.flatten).uniq
  end

  def collect_clients_have_recent_assessment_dates(client_ids_recent_assessment_dates)
    max_assessment_duration = current_setting.max_assessment_duration
    client_ids_recent_assessment_dates.map { |obj| [obj.id, obj&.assessment_created_at] }.uniq.map do |client_id, recent_assessment_date|
      next_assessment_date = recent_assessment_date + max_assessment_duration
      repeat_notifications = current_setting.two_weeks_assessment_reminder? ? [(next_assessment_date - TWO_WEEKS), (next_assessment_date - ONE_WEEK)] : [next_assessment_date - ONE_WEEK]
      client_id if repeat_notifications.include?(Date.today)
    end.compact
  end

  def collect_clients_have_recent_custom_assessment_dates(client_ids_recent_assessment_dates, custom_assessment_setting)
    client_ids_recent_assessment_dates.map { |obj| [obj.id, obj&.assessment_created_at] }.uniq.map do |client_id, recent_assessment_date|
      next_assessment_date = recent_assessment_date + assessment_duration('max', false, custom_assessment_setting.id)
      repeat_notifications = current_setting.two_weeks_assessment_reminder? ? [(next_assessment_date - TWO_WEEKS), (next_assessment_date - ONE_WEEK)] : [next_assessment_date - ONE_WEEK]
      client_id if repeat_notifications.include?(Date.today)
    end.compact
  end
end
