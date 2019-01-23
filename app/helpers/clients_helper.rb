module ClientsHelper
  def user(user)
    if can? :read, User
      link_to user.name, user_path(user) if user.present?
    elsif user.present?
      user.name
    end
  end

  def order_case_worker(client)
    client.users.order('lower(first_name)', 'lower(last_name)')
  end

  def partner(partner)
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family(family)
    family_name = family.name.present? ? family.name : 'Unknown'
    if can? :manage, :all
      link_to family_name, family_path(family)
    else
      family_name
    end
  end

  def report_options(title, yaxis_title)
    {
      library: {
        legend: {
          verticalAlign: 'top',
          y: 30
        },
        tooltip: {
          shared: true,
          xDateFormat: '%b %Y'
        },
        title: {
          text: title
        },
        xAxis: {
          dateTimeLabelFormats: {
            month: '%b %Y'
          },
          tickmarkPlacement: 'on'
        },
        yAxis: {
          allowDecimals: false,
          title: {
            text: yaxis_title
          }
        }
      }
    }
  end

  def columns_visibility(column)
    label_column = {
      slug:                          t('datagrid.columns.clients.id'),
      kid_id:                        t('datagrid.columns.clients.kid_id'),
      code:                          t('datagrid.columns.clients.code'),
      age:                           t('datagrid.columns.clients.age'),
      given_name:                    t('datagrid.columns.clients.given_name'),
      family_name:                   t('datagrid.columns.clients.family_name'),
      local_given_name:              "#{t('datagrid.columns.clients.local_given_name')} #{country_scope_label_translation}",
      local_family_name:             "#{t('datagrid.columns.clients.local_family_name')} #{country_scope_label_translation}",
      gender:                        t('datagrid.columns.clients.gender'),
      date_of_birth:                 t('datagrid.columns.clients.date_of_birth'),
      birth_province_id:             t('datagrid.columns.clients.birth_province'),
      status:                        t('datagrid.columns.clients.status'),
      received_by_id:                t('datagrid.columns.clients.received_by'),
      followed_up_by_id:             t('datagrid.columns.clients.follow_up_by'),
      initial_referral_date:         t('datagrid.columns.clients.initial_referral_date'),
      referral_phone:                t('datagrid.columns.clients.referral_phone'),
      referral_source_id:            t('datagrid.columns.clients.referral_source'),
      follow_up_date:                t('datagrid.columns.clients.follow_up_date'),
      agencies_name:                 t('datagrid.columns.clients.agencies_involved'),
      donors_name:                   t('datagrid.columns.clients.donor'),
      province_id:                   t('datagrid.columns.clients.current_province'),
      current_address:               t('datagrid.columns.clients.current_address'),
      house_number:                  t('datagrid.columns.clients.house_number'),
      street_number:                 t('datagrid.columns.clients.street_number'),
      village:                       t('datagrid.columns.clients.village'),
      commune:                       t('datagrid.columns.clients.commune'),
      district:                      t('datagrid.columns.clients.district'),
      school_name:                   t('datagrid.columns.clients.school_name'),
      school_grade:                  t('datagrid.columns.clients.school_grade'),
      able_state:                    t('datagrid.columns.clients.able_state'),
      has_been_in_orphanage:         t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care:   t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information: t('datagrid.columns.clients.relevant_referral_information'),
      user_ids:                      t('datagrid.columns.clients.case_worker'),
      state:                         t('datagrid.columns.clients.state'),
      family_id:                     t('datagrid.columns.clients.family_id'),
      family:                        t('datagrid.columns.clients.family'),
      any_assessments:               t('datagrid.columns.clients.assessments'),
      case_note_date:                t('datagrid.columns.clients.case_note_date'),
      case_note_type:                t('datagrid.columns.clients.case_note_type'),
      date_of_assessments:           t('datagrid.columns.clients.date_of_assessments'),
      date_of_custom_assessments:    t('datagrid.columns.clients.date_of_custom_assessments'),
      changelog:                     t('datagrid.columns.clients.changelog'),
      live_with:                     t('datagrid.columns.clients.live_with'),
      # id_poor:                       t('datagrid.columns.clients.id_poor'),
      program_streams:               t('datagrid.columns.clients.program_streams'),
      program_enrollment_date:       t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date:             t('datagrid.columns.clients.program_exit_date'),
      accepted_date:                 t('datagrid.columns.clients.ngo_accepted_date'),
      telephone_number:              t('datagrid.columns.clients.telephone_number'),
      exit_date:                     t('datagrid.columns.clients.ngo_exit_date'),
      created_at:                    t('datagrid.columns.clients.created_at'),
      created_by:                    t('datagrid.columns.clients.created_by'),
      referred_to:                    t('datagrid.columns.clients.referred_to'),
      referred_from:                    t('datagrid.columns.clients.referred_from')
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def ec_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def fc_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def kc_manageable
    current_user.admin? || current_user.case_worker? || current_user.manager?
  end

  def client_custom_fields_list(object)
    content_tag(:ul, class: 'client-custom-fields-list') do
      if params[:data] == 'recent'
        object.custom_field_properties.order(created_at: :desc).first.try(:custom_field).try(:form_title)
      else
        object.custom_fields.uniq.each do |obj|
          concat(content_tag(:li, obj.form_title))
        end
      end
    end
  end

  def merged_address(client)
    current_address = []
    current_address << "#{I18n.t('datagrid.columns.clients.house_number')} #{client.house_number}" if client.house_number.present?
    current_address << "#{I18n.t('datagrid.columns.clients.street_number')} #{client.street_number}" if client.street_number.present?

    if locale == :km
      current_address << "#{I18n.t('datagrid.columns.clients.village')} #{client.village.name_kh}" if client.village.present?
      current_address << "#{I18n.t('datagrid.columns.clients.commune')} #{client.commune.name_kh}" if client.commune.present?
      current_address << client.district_name.split(' / ').first if client.district.present?
      current_address << client.province_name.split(' / ').first if client.province.present?
    else
      current_address << "#{I18n.t('datagrid.columns.clients.village')} #{client.village.name_en}" if client.village.present?
      current_address << "#{I18n.t('datagrid.columns.clients.commune')} #{client.commune.name_en}" if client.commune.present?
      current_address << client.district_name.split(' / ').last if client.district.present?
      current_address << client.province_name.split(' / ').last if client.province.present?
    end
    current_address << 'Cambodia'
  end

  def format_array_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.reject(&:empty?).gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def check_is_array_date?(properties)
    properties.is_a?(Array) && properties.flatten.all?{|value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ? properties.map{|value| date_format(value.to_date) } : properties
  end

  def check_is_string_date?(property)
    (DateTime.strptime(property, '%Y-%m-%d') rescue nil).present? ? date_format(property.to_date) : property
  end

  def format_properties_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.delete_if(&:empty?).map{|c| c.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')}).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def field_not_blank?(value)
    value.is_a?(Array) ? value.delete_if(&:empty?).present? : value.present?
  end

  # legacy method
  def form_builder_format_key(value)
    value.downcase.parameterize('_')
  end

  def form_builder_format(value)
    value.split('__').last
  end

  def form_builder_format_header(value)
    entities  = { formbuilder: 'Custom form', exitprogram: 'Exit program', tracking: 'Tracking', enrollment: 'Enrollment', enrollmentdate: 'Enrollment', programexitdate: 'Exit program' }
    key_word  = value.first
    entity    = entities[key_word.to_sym]
    value     = value - [key_word]
    result    = value << entity
    result.join(' | ')
  end

  # legacy method
  def group_entity_by(value)
    value.group_by{ |field| field.split('_').first}
  end

  def format_class_header(value)
    values = value.split('|')
    name   = values.first.strip
    label  = values.last.strip
    keyword = "#{name} #{label}"
    keyword.downcase.parameterize('_')
  end

  # legacy method
  def field_not_render(field)
    field.split('_').first
  end

  def all_csi_assessment_lists(object)
    content_tag(:ul) do
      if params[:data] == 'recent'
        object.latest_record.try(:basic_info)
      else
        object.each do |assessment|
          concat(content_tag(:li, assessment.basic_info))
        end
      end
    end
  end

  def check_params_no_case_note
    true if params.dig(:client_grid, :no_case_note) == 'Yes'
  end

  def check_params_has_over_forms
    true if params.dig(:client_grid, :overdue_forms) == 'Yes'
  end

  def check_params_has_over_assessment
    true if params.dig(:client_grid, :assessments_due_to) == 'Overdue'
  end

  def check_params_has_overdue_task
    true if params.dig(:client_grid, :overdue_task) == 'Overdue'
  end

  def status_exited?(value)
    value == 'Exited'
  end

  def selected_country
    country = Setting.first.try(:country_name) || params[:country].presence
    country.nil? ? 'cambodia' : country
  end

  def country_address_field(client)
    country = selected_country
    current_address = []
    case country
    when 'thailand'
      current_address << client.plot if client.plot.present?
      current_address << client.road if client.road.present?
      current_address << client.subdistrict_name if client.subdistrict.present?
      current_address << client.district_name if client.district.present?
      current_address << client.province_name if client.province.present?
      current_address << client.postal_code if client.postal_code.present?
      current_address << 'Thailand'
    when 'lesotho'
      current_address << client.suburb if client.suburb.present?
      current_address << client.description_house_landmark if client.description_house_landmark.present?
      current_address << client.directions if client.directions.present?
      current_address << 'Lesotho'
    when 'myanmar'
      current_address << client.street_line1 if client.street_line1.present?
      current_address << client.street_line2 if client.street_line2.present?
      current_address << client.township_name if client.township.present?
      current_address << client.state_name if client.state.present?
      current_address << 'Myanmar'
    else
      current_address = merged_address(client)
    end
    current_address.compact.join(', ')
  end

  def default_columns_visibility(column)
    label_column = {
      live_with_: t('datagrid.columns.clients.live_with'),
      exit_reasons_: t('datagrid.columns.clients.exit_reasons'),
      exit_circumstance_: t('datagrid.columns.clients.exit_circumstance'),
      other_info_of_exit_: t('datagrid.columns.clients.other_info_of_exit'),
      exit_note_: t('datagrid.columns.clients.exit_note'),
      what3words_: t('datagrid.columns.clients.what3words'),
      name_of_referee_: t('datagrid.columns.clients.name_of_referee'),
      rated_for_id_poor_: t('datagrid.columns.clients.rated_for_id_poor'),
      main_school_contact_: t('datagrid.columns.clients.main_school_contact'),
      program_streams_: t('datagrid.columns.clients.program_streams'),
      given_name_: t('datagrid.columns.clients.given_name'),
      family_name_: t('datagrid.columns.clients.family_name'),
      local_given_name_: "#{t('datagrid.columns.clients.local_given_name')} (#{country_scope_label_translation})",
      local_family_name_: "#{t('datagrid.columns.clients.local_family_name')} (#{country_scope_label_translation})",
      gender_: t('datagrid.columns.clients.gender'),
      date_of_birth_: t('datagrid.columns.clients.date_of_birth'),
      status_: t('datagrid.columns.clients.status'),
      birth_province_id_: t('datagrid.columns.clients.birth_province'),
      initial_referral_date_: t('datagrid.columns.clients.initial_referral_date'),
      referral_phone_: t('datagrid.columns.clients.referral_phone'),
      received_by_id_: t('datagrid.columns.clients.received_by'),
      referral_source_id_: t('datagrid.columns.clients.referral_source'),
      followed_up_by_id_: t('datagrid.columns.clients.follow_up_by'),
      follow_up_date_: t('datagrid.columns.clients.follow_up_date'),
      agencies_name_: t('datagrid.columns.clients.agencies_involved'),
      donors_name_: t('datagrid.columns.clients.donor'),
      province_id_: t('datagrid.columns.clients.current_province'),
      current_address_: t('datagrid.columns.clients.current_address'),
      house_number_: t('datagrid.columns.clients.house_number'),
      street_number_: t('datagrid.columns.clients.street_number'),
      village_: t('datagrid.columns.clients.village'),
      commune_: t('datagrid.columns.clients.commune'),
      district_: t('datagrid.columns.clients.district'),
      school_name_: t('datagrid.columns.clients.school_name'),
      school_grade_: t('datagrid.columns.clients.school_grade'),
      has_been_in_orphanage_: t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care_: t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information_: t('datagrid.columns.clients.relevant_referral_information'),
      user_ids_: t('datagrid.columns.clients.case_worker'),
      state_: t('datagrid.columns.clients.state'),
      accepted_date_: t('datagrid.columns.clients.ngo_accepted_date'),
      exit_date_: t('datagrid.columns.clients.ngo_exit_date'),
      history_of_disability_and_or_illness_: t('datagrid.columns.clients.history_of_disability_and_or_illness'),
      history_of_harm_: t('datagrid.columns.clients.history_of_harm'),
      history_of_high_risk_behaviours_: t('datagrid.columns.clients.history_of_high_risk_behaviours'),
      reason_for_family_separation_: t('datagrid.columns.clients.reason_for_family_separation'),
      rejected_note_: t('datagrid.columns.clients.rejected_note'),
      family_: t('datagrid.columns.clients.placements.family'),
      code_: t('datagrid.columns.clients.code'),
      age_: t('datagrid.columns.clients.age'),
      slug_: t('datagrid.columns.clients.id'),
      kid_id_: t('datagrid.columns.clients.kid_id'),
      family_id_: t('datagrid.columns.families.code'),
      case_note_date_: t('datagrid.columns.clients.case_note_date'),
      case_note_type_: t('datagrid.columns.clients.case_note_type'),
      date_of_assessments_: t('datagrid.columns.clients.date_of_assessments'),
      all_csi_assessments_: t('datagrid.columns.clients.all_csi_assessments'),
      date_of_custom_assessments_: t('datagrid.columns.clients.date_of_custom_assessments'),
      all_custom_csi_assessments_: t('datagrid.columns.clients.all_custom_csi_assessments'),
      manage_: t('datagrid.columns.clients.manage'),
      changelog_: t('datagrid.columns.changelog'),
      telephone_number_: t('datagrid.columns.clients.telephone_number'),
      subdistrict_: t('datagrid.columns.clients.subdistrict'),
      township_: t('datagrid.columns.clients.township'),
      postal_code_: t('datagrid.columns.clients.postal_code'),
      road_: t('datagrid.columns.clients.road'),
      plot_: t('datagrid.columns.clients.plot'),
      street_line1_: t('datagrid.columns.clients.street_line1'),
      street_line2_: t('datagrid.columns.clients.street_line2'),
      suburb_: t('datagrid.columns.clients.suburb'),
      directions_: t('datagrid.columns.clients.directions'),
      description_house_landmark_: t('datagrid.columns.clients.description_house_landmark'),
      created_at_: t('datagrid.columns.clients.created_at'),
      created_by_: t('datagrid.columns.clients.created_by'),
      referred_to_: t('datagrid.columns.clients.referred_to'),
      referred_from_: t('datagrid.columns.clients.referred_from'),
      time_in_care_: t('datagrid.columns.clients.time_in_care')
    }

    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_identity
      label_column = label_column.merge!("#{field}_": identity)
    end
    QuantitativeType.joins(:quantitative_cases).uniq.each do |quantitative_type|
      field = quantitative_type.name
      label_column = label_column.merge!("#{field}_": quantitative_type.name)
    end
    label_column[column.to_sym]
  end

  def quantitative_type_readable?(quantitative_type_id)
    current_user.admin? || current_user.strategic_overviewer? || @quantitative_type_readable_ids.include?(quantitative_type_id)
  end

  def quantitative_type_cannot_editable?(quantitative_type_id)
    return false if current_user.admin?
    return true if @quantitative_type_editable_ids.exclude?(quantitative_type_id)
  end

  def header_classes(grid, column)
    klasses = datagrid_column_classes(grid, column).split(' ')
    return klasses.first if klasses.include?('form-builder')
    klasses.last
  end

  def client_advanced_search_data(object, rule)
    @data = {}
    return object unless params.key?(:client_advanced_search)
    @data   = eval params[:client_advanced_search][:basic_rules]
    @data[:rules].reject{ |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
  end

  def mapping_query_string(object, hashes, association, rule)
    param_values = []
    sql_string   = []
    hashes[rule].each do |rule|
      rule.keys.each do |key|
        values = rule[key]
        case key
        when 'equal'
          sql_string << "#{association} = ?"
          param_values << values
        when 'not_equal'
          sql_string << "#{association} != ?"
          param_values << values
        when 'is_empty'
          sql_string << "#{association} IS NULL"
        when 'is_not_empty'
          sql_string << "#{association} IS NOT NULL"
        else
          object
        end
      end
    end
    { sql_string: sql_string, values: param_values }
  end

  def program_stream_name(object, rule)
    hashes          = Hash.new { |h, k| h[k] = [] }

    results         = client_advanced_search_data(object, rule)
    return object if return_default_filter(object, rule, results)
    results.each { |k, o, v| hashes[k] << { o => v } }
    sql_hash        = mapping_query_string(object, hashes, 'client_enrollments.program_stream_id', rule)

    sub_query_array = mapping_sub_query_array(object, 'client_enrollments.program_stream_id', rule)
    query_array     = mapping_query_string_with_query_value(sql_hash, @data[:condition])
    sql_string      = object.where(query_array).where(sub_query_array)

    sql_string.present? ? sql_string : []
  end

  def mapping_sub_query_array(object, association, rule)
    sub_query_array = []
    if @data[:rules]
      sub_rule_index  = @data[:rules].index { |param| param.key?(:condition)}
      if sub_rule_index.present?
        sub_hashes      = Hash.new { |h, k| h[k] = [] }
        sub_results     = @data[:rules][sub_rule_index]
        sub_result_hash = sub_results[:rules].reject{ |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
        sub_result_hash.each { |k, o, v| sub_hashes[k] << { o => v } }
        sub_sql_hash    = mapping_query_string(object, sub_hashes, association, rule)
        sub_query_array = mapping_query_string_with_query_value(sub_sql_hash, sub_results[:condition])
      end
    end
    sub_query_array
  end

  def case_note_query(object, rule)
    return object if !params.key?(:client_advanced_search)

    data    = {}
    rules   = %w( case_note_date case_note_type )
    data    = eval params[:client_advanced_search][:basic_rules]

    result1                = mapping_param_value(data, 'case_note_date')
    result2                = mapping_param_value(data, 'case_note_type')

    default_value_param    = params['all_values']

    if default_value_param == 'case_note_date'
      return case_note_date_all_value(object, data, result2, rule, default_value_param)
    elsif default_value_param == 'case_note_type'
      return case_note_type_all_value(object, data, result1, rule, default_value_param)
    end

    case_note_date_hashes  = mapping_query_result(result1)
    case_note_type_hashes  = Hash.new { |h, k| h[k] = [] }
    result2.each { |k, o, v| case_note_type_hashes[k] << { o => v } }

    sub_case_note_date_query, sub_case_note_type_query = sub_query_results(object, data)

    sql_case_note_date_hash = mapping_query_date(object, case_note_date_hashes, 'case_notes.meeting_date')
    sql_case_note_type_hash = mapping_query_string(object, case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')

    case_note_date_query    = mapping_query_string_with_query_value(sql_case_note_date_hash, data[:condition])
    case_note_type_query    = mapping_query_string_with_query_value(sql_case_note_type_hash, data[:condition])

    if case_note_date_query.present? && case_note_type_query.blank?
      object = object.where(case_note_date_query).where(sub_case_note_date_query)
    elsif case_note_type_query.present? && case_note_date_query.blank?
      object = object.where(case_note_type_query).where(sub_case_note_type_query)
    else
      if data[:condition] == 'AND'
        object = object.where(case_note_date_query).where(case_note_type_query).where(sub_case_note_type_query).where(sub_case_note_date_query)
      else
        if sub_case_note_type_query.first.blank? && sub_case_note_date_query.first.blank?
          object = case_note_query_results(object, case_note_date_query, case_note_type_query)
        elsif sub_case_note_date_query.first.present? && sub_case_note_type_query.first.blank?
          object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_date_query))
        elsif sub_case_note_type_query.first.present? && sub_case_note_date_query.first.blank?
          object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_type_query))
        else
          object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_type_query)).or(object.where(sub_case_note_date_query_array))
        end
      end
    end
    object.present? ? object : []
  end

  def case_note_query_results(object, case_note_date_query, case_note_type_query)
    results = []
    if case_note_date_query.first.present? && case_note_type_query.first.blank?
      results = object.where(case_note_date_query)
    elsif case_note_date_query.first.blank? && case_note_type_query.first.present?
      results = object.where(case_note_type_query)
    else
      results = object.where(case_note_date_query).or(object.where(case_note_type_query))
    end
    results
  end

  def sub_query_results(object, data)
    sub_case_note_date_query = ['']
    sub_case_note_type_query = ['']
    if data[:rules]
      sub_rule_index  = data[:rules].index { |param| param.key?(:condition)}
      if sub_rule_index.present?
        sub_case_note_date_results     = data[:rules][sub_rule_index]
        sub_case_note_date_result_hash = mapping_param_value(sub_case_note_date_results, 'case_note_date')
        sub_case_note_date_hashes      = mapping_query_result(sub_case_note_date_result_hash)
        sub_case_note_date_sql_hash    = mapping_query_date(object, sub_case_note_date_hashes, 'case_notes.meeting_date')
        sub_case_note_date_query       = mapping_query_string_with_query_value(sub_case_note_date_sql_hash, sub_case_note_date_results[:condition])

        sub_case_note_type_hashes      = Hash.new { |h, k| h[k] = [] }
        sub_case_note_type_results     = data[:rules][sub_rule_index]
        sub_case_note_type_result_hash = mapping_param_value(sub_case_note_type_results, 'case_note_type')
        sub_case_note_type_result_hash.each { |k, o, v| sub_case_note_type_hashes[k] << { o => v } }
        sub_case_note_type_sql_hash    = mapping_query_string(object, sub_case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')
        sub_case_note_type_query       = mapping_query_string_with_query_value(sub_case_note_type_sql_hash, data[:condition])
      end
    end
    [sub_case_note_date_query, sub_case_note_type_query]
  end

  def case_note_date_all_value(object, data, results, rule, default_value_param)
    return if default_value_param.blank?
    if rule == default_value_param
      return object
    else
      sub_case_note_type_query = ['']
      case_note_type_hashes    = Hash.new { |h, k| h[k] = [] }
      results.each { |k, o, v| case_note_type_hashes[k] << { o => v } }
      sql_case_note_type_hash  = mapping_query_string(object, case_note_type_hashes, 'case_notes.interaction_type', 'case_note_type')
      case_note_type_query     = mapping_query_string_with_query_value(sql_case_note_type_hash, data[:condition])
      sub_case_note_type_query = sub_query_results(object, data).last
      if data[:condition] == 'AND'
        if sub_case_note_type_query.first.blank?
          object = object.where(case_note_type_query)
        else
          object = object.where(case_note_type_query).where(sub_case_note_type_query)
        end
      else
        if sub_case_note_type_query.first.blank?
          object = object.where(case_note_type_query)
        else
          object = object.where(case_note_type_query).or(object.where(sub_case_note_type_query))
        end
      end
      return object
    end
  end

  def case_note_type_all_value(object, data, results, rule, default_value_param)
    return if default_value_param.blank?

    sub_case_note_date_query = ['']
    case_note_date_hashes    = mapping_query_result(results)
    sql_case_note_date_hash  = mapping_query_date(object, case_note_date_hashes, 'case_notes.meeting_date')
    case_note_date_query     = mapping_query_string_with_query_value(sql_case_note_date_hash, data[:condition])
    sub_case_note_date_query = sub_query_results(object, data).first
    if data[:condition] == 'AND'
      if sub_case_note_date_query.first.blank?
        object = object.where(case_note_date_query)
      else
        object = object.where(case_note_date_query).where(sub_case_note_date_query)
      end
    else
      if sub_case_note_date_query.first.blank?
        object = object.where(case_note_date_query)
      else
        object = object.where(case_note_date_query).or(object.where(sub_case_note_date_query))
      end
    end
    return object
  end

  def mapping_param_value(data, rule)
    data[:rules].reject{ |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
  end

  def date_filter(object, rule)
    query_array      = []
    sub_query_array  = []
    field_name       = ''
    results          = client_advanced_search_data(object, rule)

    return object if return_default_filter(object, rule, results)

    klass_name  = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', meeting_date: 'case_notes', case_note_type: 'case_notes', created_at: 'assessments' }

    if rule == 'case_note_date'
      field_name = 'meeting_date'
    elsif rule.in?(['date_of_assessments', 'date_of_custom_assessments'])
      field_name = 'created_at'
    elsif rule[/^(programexitdate)/i].present? || object.class.to_s[/^(leaveprogram)/i]
      klass_name.merge!(rule => 'leave_programs')
      field_name = 'exit_date'
    elsif rule[/^(enrollmentdate)/i].present?
      klass_name.merge!(rule => 'client_enrollments')
      field_name = 'enrollment_date'
    else
      field_name = rule
    end

    relation = rule[/^(enrollmentdate)|^(programexitdate)/i] ? "#{klass_name[rule]}.#{field_name}" : "#{klass_name[field_name.to_sym]}.#{field_name}"

    hashes   = mapping_query_result(results)
    sql_hash = mapping_query_date(object, hashes, relation)

    if @data[:rules]
      sub_rule_index  = @data[:rules].index { |param| param.key?(:condition)}
      if sub_rule_index.present?
        sub_results     = @data[:rules][sub_rule_index]
        sub_result_hash = sub_results[:rules].reject{ |h| h[:id] != rule }.map { |value| [value[:id], value[:operator], value[:value]] }
        sub_hashes      = mapping_query_result(sub_result_hash)
        sub_sql_hash    = mapping_query_date(object, sub_hashes, relation)
        sub_query_array = mapping_query_string_with_query_value(sub_sql_hash, sub_results[:condition])
      end
    end

    query_array = mapping_query_string_with_query_value(sql_hash, @data[:condition])
    sql_string = object.where(query_array).where(sub_query_array)

    sql_string.present? && sql_hash[:sql_string].present? ? sql_string : []
  end

  def header_counter(grid, column)
    return column.header.truncate(65) if grid.class.to_s != 'ClientGrid' || @clients.blank?
    count = 0
    class_name  = header_classes(grid, column)

    if Client::HEADER_COUNTS.include?(class_name) || class_name[/^(enrollmentdate)/i] || class_name[/^(programexitdate)/i]
      association = "#{class_name}_count"
      klass_name  = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', case_note_date: 'case_notes', case_note_type: 'case_notes', date_of_assessments: 'assessments', date_of_custom_assessments: 'assessments' }

      if class_name[/^(programexitdate)/i].present? || class_name[/^(leaveprogram)/i]
        klass     = 'leave_programs'
      elsif class_name[/^(enrollmentdate)/i].present? || column.header == I18n.t('datagrid.columns.clients.program_streams')
        klass     = 'client_enrollments'
      else
        klass     = klass_name[class_name.to_sym]
      end

      if class_name[/^(programexitdate)/i].present?
        ids = @clients.map { |client| client.client_enrollments.inactive.ids }.flatten.uniq
        object = LeaveProgram.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }, leave_programs: { client_enrollment_id: ids })
        count += date_filter(object, class_name).flatten.count
      else
        @clients.each do |client|
          if class_name == 'case_note_type'
            count += case_note_query(client.send(klass.to_sym), class_name).count
          elsif class_name == 'case_note_date'
            count += case_note_query(client.send(klass.to_sym), class_name).count
          elsif column.header == I18n.t('datagrid.columns.clients.program_streams')
            class_name = 'active_program_stream'
            program_stream_name_active = program_stream_name(client.send(klass.to_sym).active, class_name)
            if program_stream_name_active.present?
              count += program_stream_name(client.send(klass.to_sym).active, class_name).count
            else
              count += client.send(klass.to_sym).active.count
            end
          elsif class_name[/^(enrollmentdate)/i].present?
            data_filter = date_filter(client.client_enrollments.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }), "#{class_name} Date")
            count += data_filter.map(&:enrollment_date).flatten.count if data_filter.present?
          elsif class_name[/^(date_of_assessments)/i]
            count += client.send(klass.to_sym).defaults.count
          elsif class_name[/^(date_of_custom_assessments)/i]
            count += client.send(klass.to_sym).customs.count
          else
            count += date_filter(client.send(klass.to_sym), class_name).flatten.count
          end
        end
      end

      if count > 0 && class_name != 'case_note_type'
        link_all = params['all_values'] != class_name ? content_tag(:a, 'All', class: 'all-values', href: "#{url_for(params)}&all_values=#{class_name}") : ''
        [column.header.truncate(65),
          content_tag(:span, count, class: 'label label-info'),
          link_all
        ].join(' ').html_safe
      else
        column.header.truncate(65)
      end
    else
      column.header.truncate(65)
    end
  end

  def case_history_label(value)
    label = case value.class.table_name
            when 'enter_ngos' then t('.accepted_date')
            when 'exit_ngos' then t('.exit_date')
            when 'client_enrollments' then "#{value.program_stream.name} Entry"
            when 'leave_programs' then "#{value.program_stream.name} Exit"
            when 'referrals'
              if value.referred_to == current_organization.short_name
                "#{t('.internal_referral')}: #{value.referred_from_ngo}"
              else
                "#{t('.external_referral')}: #{value.referred_to_ngo}"
              end
            end
    label
  end

  def international_referred_client
    params[:referral_id].present? && @client.country_origin != selected_country
  end

  def mapping_query_result(results)
    hashes  = values = Hash.new { |h, k| h[k] = [] }
    results.each do |k, o, v|
      values[o] << v
      hashes[k] << values
    end

    hashes.keys.each do |value|
      arr = hashes[value]
      hashes.delete(value)
      hashes[value] << arr.uniq
    end
    hashes
  end

  def mapping_query_date(object, hashes, relation)
    sql_string    = []
    param_values  = []
    hashes.keys.each do |key|
      values   = hashes[key].flatten
      case key
      when 'between'
        sql_string << "date(#{relation}) BETWEEN ? AND ?"
        param_values << values.first
        param_values << values.last
      when 'greater_or_equal'
        sql_string << "date(#{relation}) >= ?"
        param_values << values
      when 'greater'
        sql_string << "date(#{relation}) > ?"
        param_values << values
      when 'less'
        sql_string << "date(#{relation}) < ?"
        param_values << values
      when 'less_or_equal'
        sql_string << "date(#{relation}) <= ?"
        param_values << values
      when 'not_equal'
        sql_string << "date(#{relation}) NOT IN (?)"
        param_values << values
      when 'equal'
        sql_string << "date(#{relation}) IN (?)"
        param_values << values
      when 'is_empty'
        sql_string << "date(#{relation}) IS NULL"

      when 'is_not_empty'
        sql_string << "date(#{relation}) IS NOT NULL"
      else
        object
      end
    end

    { sql_string: sql_string, values: param_values }
  end

  def mapping_query_string_with_query_value(sql_hash, condition)
    query_array = []
    query_array << sql_hash[:sql_string].join(" #{condition} ")
    sql_hash[:values].map { |v| query_array << v }
    query_array
  end

  def return_default_filter(object, rule, results)
    rule[/^(#{params['all_values']})/i].present? || object.blank? || results.blank? || results.class.name[/activerecord/i].present?
  end

  def case_workers_option(client_id)
    @users.map do |user|
      tasks = user.tasks.incomplete.where(client_id: client_id)
      if tasks.any?
        [user.name, user.id, { locked: 'locked'} ]
      else
        [user.name, user.id]
      end
    end
  end

  def case_history_links(case_history, case_history_name)
    case case_history_name
    when 'client_enrollments'
      link_to edit_client_client_enrollment_path(@client, case_history, program_stream_id: case_history.program_stream_id) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    when 'leave_programs'
      enrollment = @client.client_enrollments.find(case_history.client_enrollment_id)
      link_to edit_client_client_enrollment_leave_program_path(@client, enrollment, case_history) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    end
  end

  def render_case_history(case_history, case_history_name)
    case case_history_name
    when 'enter_ngos'
      render 'client/enter_ngos/edit_form', client: @client, enter_ngo: case_history
    when 'exit_ngos'
      render 'client/exit_ngos/edit_form', client: @client, exit_ngo: case_history
    end
  end

  def date_format(date)
    date.strftime('%d %B %Y') if date.present?
  end


  def country_scope_label_translation
    if I18n.locale.to_s == 'en'
      country_name = Organization.current.short_name == 'cccu' ? 'uganda' : Setting.first.try(:country_name)
      case country_name
      when 'cambodia' then '(Khmer)'
      when 'thailand' then '(Thai)'
      when 'myanmar' then '(Burmese)'
      when 'lesotho' then '(Sesotho)'
      when 'uganda' then '(Swahili)'
      else
        '(Unknown)'
      end
    end
  end

  def client_alias_id
    current_organization.short_name == 'fts' ? @client.code : @client.slug
  end

  # we use dataTable export button instead
  # def to_spreadsheet(assessment_type)
  #   column_header = [
  #                     I18n.t('clients.assessment_domain_score.client_id'), I18n.t('clients.assessment_domain_score.client_name'),
  #                     I18n.t('clients.assessment_domain_score.assessment_number'), I18n.t('clients.assessment_domain_score.assessment_date'),
  #                     Domain.pluck(:name)
  #                   ]
  #   book = Spreadsheet::Workbook.new
  #   book.create_worksheet
  #   book.worksheet(0).insert_row(0, column_header.flatten)
  #
  #   ordering = 0
  #   assessment_domain_hash = {}
  #
  #   assets.includes(assessments: :assessment_domains).reorder(id: :desc).each do |client|
  #     assessments = assessment_type == 'default' ? client.assessments.defaults : assessment_type == 'custom' ? client.assessments.customs : client.assessments
  #     if assessment_type == 'default'
  #       assessments = client.assessments.defaults
  #       domains = Domain.csi_domains
  #     elsif assessment_type == 'custom'
  #       assessments = client.assessments.customs
  #       domains = Domain.custom_csi_domains
  #     else
  #       assessments = client.assessments
  #       domains = Domain.all
  #     end
  #
  #     assessments.each_with_index do |assessment, index|
  #       assessment_domain_hash = assessment.assessment_domains.pluck(:domain_id, :score).to_h if assessment.assessment_domains.present?
  #       domain_scores = domains.map { |domain| assessment_domain_hash.present? ? assessment_domain_hash[domain.id] : '' }
  #       book.worksheet(0).insert_row (ordering += 1), [client.slug, client.en_and_local_name, index + 1, date_format(assessment.created_at), domain_scores].flatten
  #     end
  #   end
  #
  #   buffer = StringIO.new
  #   book.write(buffer)
  #   buffer.rewind
  #   buffer.read
  # end
end
