module AdvancedSearchHelper

  def format_header(key)
    translations = {
      first_name: I18n.t('advanced_search.fields.first_name'),
      last_name: I18n.t('advanced_search.fields.last_name'),
      local_first_name: I18n.t('advanced_search.fields.local_first_name'),
      local_last_name: I18n.t('advanced_search.fields.local_last_name'),
      code: I18n.t('advanced_search.fields.code'),
      grade: I18n.t('advanced_search.fields.grade'),
      family_id: I18n.t('advanced_search.fields.family_id'),
      age: I18n.t('advanced_search.fields.age'),
      first_name: I18n.t('advanced_search.fields.first_name'),
      family_name: I18n.t('advanced_search.fields.family_name'),
      slug: I18n.t('advanced_search.fields.slug'),
      referral_phone: I18n.t('advanced_search.fields.referral_phone'),
      school_name: I18n.t('advanced_search.fields.school_name'),
      placement_date: I18n.t('advanced_search.fields.placement_date'),
      date_of_birth: I18n.t('advanced_search.fields.date_of_birth'),
      initial_referral_date: I18n.t('advanced_search.fields.initial_referral_date'),
      follow_up_date: I18n.t('advanced_search.fields.follow_up_date'),
      gender: I18n.t('advanced_search.fields.gender'),
      status: I18n.t('advanced_search.fields.status'),
      case_type: I18n.t('advanced_search.fields.case_type'),
      agency_name: I18n.t('advanced_search.fields.agency_name'),
      received_by_id: I18n.t('advanced_search.fields.received_by_id'),
      birth_province_id: I18n.t('advanced_search.fields.birth_province_id'),
      province_id: I18n.t('advanced_search.fields.province_id'),
      referral_source_id: I18n.t('advanced_search.fields.referral_source_id'),
      followed_up_by_id: I18n.t('advanced_search.fields.followed_up_by_id'),
      has_been_in_government_care: I18n.t('advanced_search.fields.has_been_in_government_care'),
      able_state: I18n.t('advanced_search.fields.able_state'),
      has_been_in_orphanage: I18n.t('advanced_search.fields.has_been_in_orphanage'),
      user_id: I18n.t('advanced_search.fields.user_id')
    }
    translations[key.to_sym] || ''
  end

  def format_advanced_search_result(field_name, value)
    associated_value = {
      provinces:            ['birth_province_id', 'province_id'],
      referral_sources:     ['referral_source_id'],
      users:                ['received_by_id', 'followed_up_by_id', 'user_id'],
    }

    if field_name == 'has_been_in_orphanage' || field_name == 'has_been_in_government_care'
      value ? 'Yes' : 'No'
    elsif associated_value[:provinces].include?(field_name)
      Province.find_by(id: value).try :name
    elsif associated_value[:referral_sources].include?(field_name)
      ReferralSource.find_by(id: value).try :name
    elsif associated_value[:users].include?(field_name)
     User.find_by(id: value).try :name
    elsif field_name == 'age'
      value.date_of_birth = value.age
      pluralize(value.age_as_years, 'year') + ' ' + pluralize(value.age_extra_months, 'month') if value.present?
    else
      value
    end
  end
end
