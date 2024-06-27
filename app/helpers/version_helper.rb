module VersionHelper
  def version_attribute(k, item_type = '')
    attribute_label[:first_name] = attribute_first_name(item_type)
    attribute_label[:name]       = attribute_name(item_type)
    attribute_label[:user_id]    = attribute_user_id(item_type)
    k = attribute_label[k.to_sym] || k
    survey_score_text?(k) ? k : k.titleize
  end

  def type_assessment_domain(type, events)
    type_assessment = %w(score reason domain goal presence)
    type_assessment.include?(type) && events != 'create'
  end

  def version_domain_name(id)
    ad = AssessmentDomain.find_by(id: id)
    ad.domain.name if ad.present?
  end

  def version_value_format(val, k = '', both_val = [])
    version_values_regular.each do |key, value|
      if value.include?(k) && val.present?
        obj = model_name(key).find_by(id: val)
        val = obj.present? ? obj.name : "##{val}"
      end
      val
    end

    if k == 'birth_province_id'
      current_org = current_organization
      Organization.switch_to 'shared'
      name = Province.find_by(id: val).try(:name)
      Organization.switch_to current_org.short_name
      val = name
    elsif version_values[:titleizeTexts].include?(k)
      val = val.try(:titleize)
    elsif val.class == Date
      val = date_format(val)
    elsif any_time_class(val)
      val = date_time_format(val)

    elsif version_values[:booleans].include?(k)
      val = human_boolean(val)
    elsif version_values[:free_text].include?(k) && html?(val)
      val = strip_tags(val)
    elsif version_values[:score_colors].include?(k)
      val = domain_score_color(val)
    # elsif version_values[:currencies].include?(k)
    #   val = number_to_currency(val)

    elsif version_values[:progress_note_types].include?(k) && val.present?
      obj = ProgressNoteType.find_by(id: val)
      val = obj.present? ? obj.note_type : "##{val}"
    elsif version_values[:client_qc].include?(k) && val.present?
      obj = QuantitativeCase.find_by(id: val)
      val = obj.present? ? obj.value : "##{val}"
    elsif version_values[:materials].include?(k) && val.present?
      obj = Material.find_by(id: val)
      val = obj.present? ? obj.status : "##{val}"
    elsif version_values[:organizations].include?(k) && val.present?
      obj = Organization.find_by(id: val)
      val = obj.present? ? obj.full_name : "##{val}"
    elsif version_values[:agency].include?(k) && val.present?
      obj = Agency.find_by(id: val)
      val = obj.present? ? obj.name : "##{val}"
    elsif version_values[:donor].include?(k) && val.present?
      obj = Donor.find_by(id: val)
      val = obj.present? ? obj.name : "##{val}"
    elsif version_values[:custom_fields].include?(k) && val.present?
      obj = CustomField.find_by(id: val)
      val = obj.present? ? obj.form_title : "##{val}"
    elsif k == 'reset_password_token'
      val = content_tag(:span, truncate(val), title: val)
    end
    val
  end

  def version_item_type_active?(item_type = '', custom_formable_type = {})
    if params[:item_type] == item_type || (params[:item_type].nil? && item_type == '')
      'active'
    elsif custom_formable_type.present? && (params[:formable_type] == custom_formable_type[:formable_type])
      'active'
    end
  end

  def version_not_show(item_type)
    arr = %w(AssessmentDomain Assessment CaseNote CaseNoteDomainGroup AgencyClient Sponsor Client ClientQuantitativeCase ProgramStream Tracking ClientEnrollment ClientEnrollmentTracking Survey)
    arr.exclude?(item_type)
  end

  def version_keys_skipable?(k, item_type = '')
    keys = ['goal_required', 'required_task_last', 'country_origin', 'archive_state', 'attachments', 'admin', 'tokens', 'encrypted_password', 'uid', 'able']
    keys.include?(k) || skipable_user_task_and_case?(k, item_type)
  end

  def skipable_user_task_and_case?(k, item_type)
    (k == 'user_id' && (case?(item_type) || task?(item_type)))
  end

  def version_color(event)
    event_color = {
      create: 'primary',
      delete: 'danger',
      update: 'success'
    }
    event_color[event.to_sym]
  end

  private

  def attribute_first_name(type)
    type == 'Client' ? 'name' : 'first_name'
  end

  def attribute_name(type)
    type == 'Task' ? 'task detail' : 'name'
  end

  def attribute_user_id(type)
    if type == 'Client' || type == 'Survey'
      'case worker / staff'
    elsif type == 'ProgressNote'
      'able / able staff name'
    elsif type == 'Changelog'
      'creator'
    end
  end

  def html?(val)
    strip_tags(val) != val
  end

  def domain_score_color(type)
    domain_color = {
      danger: 'Red',
      info: 'Blue',
      success: 'Blue',
      primary: 'Green',
      warning: 'Yellow'
    }
    domain_color[type.to_sym]
  end

  def survey_score_text?(text)
    texts = [
      attribute_label[:listening_score],
      attribute_label[:problem_solving_score],
      attribute_label[:getting_in_touch_score],
      attribute_label[:trust_score],
      attribute_label[:difficulty_help_score],
      attribute_label[:support_score],
      attribute_label[:family_need_score],
      attribute_label[:care_score],
      attribute_label[:custom_field_id]

    ]
    texts.include?(text)
  end

  def task?(item_type)
    item_type == 'Task'
  end

  def case?(item_type)
    item_type == 'Case'
  end

  def model_name(key)
    eval(key.to_s.singularize.classify)
  end

  def version_values
    {
      free_text:            ['description', 'response', 'additional_note'],
      booleans:             ['has_been_in_orphanage', 'has_been_in_government_care', 'able', 'dependable_income', 'family_preservation', 'exited', 'exited_from_cif', 'alert_manager', 'calendar_integration', 'default', 'completed', 'custom'],
      titleizeTexts:        ['gender', 'state', 'family_type', 'roles'],
      assessments:          ['assessment_id'],
      score_colors:         ['score_1_color', 'score_2_color', 'score_3_color', 'score_4_color'],
      progress_note_types:  ['progress_note_type_id'],
      materials:            ['material_id'],
      # currencies:           ['household_income'],
      client_qc:            ['quantitative_case_id'],
      organizations:        ['organization_id'],
      agency:               ['agency_id'],
      donor:                ['donor_id'],
      custom_fields:        ['custom_field_id']
    }
  end

  def version_values_regular
    {
      families:             ['family_id'],
      provinces:            ['province_id'],
      referral_sources:     ['referral_source_id'],
      users:                ['received_by_id', 'followed_up_by_id', 'user_id'],
      departments:          ['department_id'],
      domain_groups:        ['domain_group_id'],
      partners:             ['partner_id'],
      quantitative_types:   ['quantitative_type_id'],
      domains:              ['domain_id'],
      locations:            ['location_id'],
      clients:              ['client_id'],
      trackings:            ['tracking_id'],
      program_streams:      ['program_stream_id'],
      organization_types:   ['organization_type_id'],
      district:             ['district_id'],
      commune:              ['commune_id'],
      village:              ['village_id']
    }
  end

  def attribute_label
    {
      change_version:         'version',
      attendee:               'present',
      listening_score:        'I feel like my CCW listens to me when I speak.',
      problem_solving_score:  'My CCW helps me solve my problems.',
      getting_in_touch_score: 'My CCW knows of other services and groups of people who can help me, and helps me get in touch with them.',
      trust_score:            'I can trust my CCW.',
      difficulty_help_score:  'CIF has helped me through difficult times in my life.',
      support_score:          'CIF has helped me through difficult times in my life.',
      family_need_score:      'I am happy with the way CIF and my CCW have supported me.',
      care_score:             'My CCW cares about what happens to the children I take care of.',
      contact_person_name:    'contact_name',
      contact_person_email:   'email',
      contact_person_mobile:  'contact_mobile',
      custom_field_id:        'Form Title',
      client_enrollment_id:   'Client Enrollment ID',
      roles:                  'Permission set',
      **client_labels
    }
  end

  def client_labels
    {
      live_with:              'Primary Carer Name',
      given_name:             'Given Name (English)',
      local_given_name:       "Given Name #{country_scope_label_translation}",
      family_name:            'Family Name (English)',
      local_family_name:      "Family Name #{country_scope_label_translation}",
      code:                   'Custom ID Number 1',
      kid_id:                 'Custom ID Number 2',
      referral_phone:         'Referee Phone Number',
      telephone_number:       'Primary Carer Phone Number',
      rated_for_id_poor:      'Is the client rated for ID poor',
      received_by_id:         'Referral Received By',
      followed_up_by_id:      'First Follow-Up By',
      follow_up_date:         'First Follow-Up Date',
      has_been_in_orphanage:  'Has the client lived in an orphanage?',
      has_been_in_government_care: 'Has the client lived in government care?'
    }
  end

  def any_time_class(val)
    val.class == ActiveSupport::TimeWithZone || val.class == Time
  end
end
