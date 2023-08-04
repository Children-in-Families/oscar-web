module FamiliesHelper
  def get_or_build_family_quantitative_free_text_cases
    @quantitative_types.map do |qtt|
      @family.family_quantitative_free_text_cases.find_or_initialize_by(quantitative_type_id: qtt.id)
    end
  end

  def family_member_list(object)
    html_tags = []

    if params[:locale] == 'km'
      html_tags << "#{I18n.t('datagrid.columns.families.female_children_count')} : #{object.female_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male_children_count')} : #{object.male_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.female_adult_count')} : #{object.female_adult_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male_adult_count')} : #{object.male_adult_count.to_i}"
    elsif params[:locale] == 'en'
      html_tags << "#{I18n.t('datagrid.columns.families.female')} #{'child'.pluralize(object.female_children_count.to_i)} : #{object.female_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male')} #{'child'.pluralize(object.male_children_count.to_i)} : #{object.male_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.female')} #{'adult'.pluralize(object.female_adult_count.to_i)}  : #{object.female_adult_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male')} #{'adult'.pluralize(object.male_adult_count.to_i)} : #{object.male_adult_count.to_i}"
    end

    content_tag(:ul, class: 'family-members-list') do
      html_tags.each do |html_tag|
        concat content_tag(:li, html_tag)
      end
    end
  end

  def readable_family_quantitative_free_text_cases
    @readable_family_quantitative_free_text_cases ||= @family.family_quantitative_free_text_cases.map do |qtt_free_text|
      next if qtt_free_text.content.blank?
      next unless quantitative_type_readable?(qtt_free_text.quantitative_type_id)

      qtt_free_text
    end.compact
  end

  def readable_viewable_quantitative_cases
    @readable_viewable_quantitative_cases ||= @family.viewable_quantitative_cases.group_by(&:quantitative_type).map do |qtypes|
      next unless quantitative_type_readable?(qtypes.first.id)
      qtypes
    end.compact
  end

  def family_clients_list(object)
    content_tag(:ul, class: 'family-clients-list') do
      object.family_members.joins(:client).each do |memeber|
        client = memeber.client
        concat(content_tag(:li, link_to(entity_name(client), client_path(client)))) if client.present?
      end
    end
  end

  def family_workers_list(client_ids)
    content_tag(:ul, class: 'family-clients-list') do
      user_ids = Client.where(id: client_ids).joins(:case_worker_clients).map(&:user_ids).flatten.uniq
      User.where(id: user_ids).each do |user|
        concat(content_tag(:li, link_to(entity_name(user), user_path(user))))
      end
    end
  end

  def family_workers_count(client_ids)
    Client.where(id: client_ids).joins(:case_worker_clients).map(&:user_ids).flatten.uniq.size
  end

  def family_case_history(object)
    if object.case_history =~ /\A#{URI::regexp(['http', 'https'])}\z/
      link_to object.case_history, object.case_history, class: 'case-history', target: :_blank
    else
      object.case_history
    end
  end

  def additional_columns
    unless Setting.cache_first.try(:hide_family_case_management_tool?)
      {
        date_of_custom_assessments: I18n.t('datagrid.columns.date_of_family_assessment'),
        all_custom_csi_assessments: I18n.t('datagrid.columns.all_custom_csi_assessments', assessment: I18n.t('families.show.assessment')),
        assessment_completed_date: I18n.t('datagrid.columns.assessment_completed_date', assessment: I18n.t('families.show.assessment')),
        custom_completed_date: I18n.t('datagrid.columns.assessment_completed_date', assessment: I18n.t('families.show.assessment')),
        care_plan_completed_date: I18n.t('datagrid.columns.clients.care_plan_completed_date'),
        care_plan_count: I18n.t('datagrid.columns.clients.care_plan_count')
      }
    else
      {}
    end
  end

  def columns_family_visibility(column)
    label_column = map_family_field_labels
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def default_family_columns_visibility(column)
    label_column = map_family_field_labels.map { |k, v| ["#{k}_", v] }.to_h
    label_tag "#{column}_", label_column[column]
  end

  def map_family_field_labels
    {
      active_families:                          I18n.t('datagrid.columns.families.active_families'),
      no_case_note_date:                        I18n.t('advanced_search.fields.no_case_note_date'),
      family_rejected:                          I18n.t('datagrid.columns.families.family_rejected'),
      number_family_billable:                   I18n.t('datagrid.columns.families.number_family_billable'),
      number_family_referred_gatekeeping:       I18n.t('datagrid.columns.families.number_family_referred_gatekeeping'),
      active_program_stream:                    I18n.t('datagrid.columns.families.program_streams'),
      care_plan:                                I18n.t('advanced_search.fields.care_plan'),
      name:                                     I18n.t('datagrid.columns.families.name'),
      name_en:                                  I18n.t('datagrid.columns.families.name_en'),
      id:                                       I18n.t('datagrid.columns.families.id'),
      code:                                     I18n.t('datagrid.columns.families.code'),
      id_poor:                                  I18n.t('datagrid.columns.families.id_poor'),
      family_type:                              I18n.t('datagrid.columns.families.family_type'),
      status:                                   I18n.t('datagrid.columns.families.status'),
      gender:                                   I18n.t('activerecord.attributes.family_member.gender'),
      date_of_birth:                            I18n.t('datagrid.columns.families.date_of_birth'),
      follow_up_date:                           I18n.t('datagrid.columns.families.follow_up_date'),
      case_history:                             I18n.t('datagrid.columns.families.case_history'),
      address:                                  I18n.t('datagrid.columns.families.address'),
      phone_number:                             I18n.t('datagrid.columns.families.phone_number'),
      significant_family_member_count:          I18n.t('datagrid.columns.families.significant_family_member_count'),
      male_children_count:                      I18n.t('datagrid.columns.families.male_children_count'),
      received_by:                              I18n.t('datagrid.columns.families.received_by'),
      received_by_id:                           I18n.t('datagrid.columns.families.received_by_id'),
      followed_up_by_id:                        I18n.t('datagrid.columns.families.followed_up_by_id'),
      referral_source_id:                       I18n.t('datagrid.columns.families.referral_source_id'),
      referral_source_category_id:              I18n.t('datagrid.columns.families.referral_source_category_id'),
      street:                                   I18n.t('datagrid.columns.families.street'),
      house:                                    I18n.t('datagrid.columns.families.house'),
      dependable_income:                        I18n.t('datagrid.columns.families.dependable_income'),
      male_adult_count:                         I18n.t('datagrid.columns.families.male_adult_count'),
      household_income:                         I18n.t('datagrid.columns.families.household_income'),
      created_at:                               I18n.t('advanced_search.fields.created_at'),
      user_id:                                  I18n.t('advanced_search.fields.created_by'),
      contract_date:                            I18n.t('datagrid.columns.families.contract_date'),
      initial_referral_date:                    I18n.t('datagrid.columns.families.initial_referral_date'),
      caregiver_information:                    I18n.t('datagrid.columns.families.caregiver_information'),
      changelog:                                I18n.t('datagrid.columns.families.changelogs'),
      case_workers:                             I18n.t('datagrid.columns.families.case_worker_name'),
      case_note_date:                           I18n.t('advanced_search.fields.case_note_date'),
      case_note_type:                           I18n.t('advanced_search.fields.case_note_type'),
      female_children_count:                    I18n.t('datagrid.columns.families.female_children_count'),
      female_adult_count:                       I18n.t('datagrid.columns.families.female_adult_count'),
      clients:                                  I18n.t('datagrid.columns.families.clients'),
      client_id:                                I18n.t('datagrid.columns.families.client'),
      manage:                                   I18n.t('datagrid.columns.families.manage'),
      program_streams:                          I18n.t('datagrid.columns.families.program_streams'),
      program_enrollment_date:                  I18n.t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date:                        I18n.t('datagrid.columns.clients.program_exit_date'),
      direct_beneficiaries:                     I18n.t('datagrid.columns.families.direct_beneficiaries'),
      relation:                                 I18n.t('families.family_member_fields.relation'),
      member_count:                             I18n.t('datagrid.columns.families.member_count'),
      date_of_custom_assessments:               I18n.t('datagrid.columns.date_of_family_assessment'),
      custom_assessment_created_at: I18n.t('datagrid.columns.family_assessment_created_at'),
      **additional_columns,
      **family_address_translation
    }
  end

  def family_address_translation(group_name = 'family')
    field_keys = %W(province province_id district district_id commune commune_id village)
    translations = {}
    field_keys.each do |key_translation|
      translations[key_translation.to_sym] = FieldSetting.cache_by_name(key_translation, group_name) || I18n.t("datagrid.columns.families.#{key_translation}")
      translations["#{key_translation}_".to_sym] = FieldSetting.cache_by_name(key_translation, group_name) || I18n.t("datagrid.columns.families.#{key_translation}")
    end
    translations['province_id'.to_sym] = FieldSetting.cache_by_name('province_id', group_name) || I18n.t('datagrid.columns.families.province')
    translations['district_id'.to_sym] = FieldSetting.cache_by_name('district_id', group_name) || I18n.t('datagrid.columns.families.district')
    translations['commune_id'.to_sym] = FieldSetting.cache_by_name('commune_id', group_name) || I18n.t('datagrid.columns.families.commune')
    translations['village_id'.to_sym] = FieldSetting.cache_by_name('village_id', group_name) || I18n.t('datagrid.columns.families.village_id')
    translations
  end

  def merged_address_family(object)
    current_address = []
    current_address << "#{I18n.t('datagrid.columns.families.house')} #{object.house}" if object.house.present?
    current_address << "#{I18n.t('datagrid.columns.families.street')} #{object.street}" if object.street.present?

    if I18n.locale.to_s == 'km'
      current_address << "#{I18n.t('datagrid.columns.families.village')} #{object.village.name_kh}" if object.village.present?
      current_address << "#{I18n.t('datagrid.columns.families.commune')} #{object.commune.name_kh}" if object.commune.present?
      current_address << object.district_name.split(' / ').first if object.district.present?
      current_address << object.province_name.split(' / ').first if object.province.present?
      current_address << 'កម្ពុជា' if Organization.current.short_name != 'brc'

    else
      current_address << "#{I18n.t('datagrid.columns.families.village')} #{object.village.name_en}" if object.village.present?
      current_address << "#{I18n.t('datagrid.columns.families.commune')} #{object.commune.name_en}" if object.commune.present?
      current_address << object.district_name.split(' / ').last if object.district.present?
      current_address << object.province_name.split(' / ').last if object.province.present?
      current_address << 'Cambodia' if Organization.current.short_name != 'brc'
    end

    current_address.join(', ')
  end

  def merged_address_community(object)
    current_address = []

    if I18n.locale.to_s == 'km'
      current_address << "#{I18n.t('datagrid.columns.families.village')} #{object.village.name_kh}" if object.village.present?
      current_address << "#{I18n.t('datagrid.columns.families.commune')} #{object.commune.name_kh}" if object.commune.present?
      current_address << object.district_name.split(' / ').first if object.district.present?
      current_address << object.province_name.split(' / ').first if object.province.present?
      current_address << 'កម្ពុជា' if Organization.current.short_name != 'brc'

    else
      current_address << "#{I18n.t('datagrid.columns.families.village')} #{object.village.name_en}" if object.village.present?
      current_address << "#{I18n.t('datagrid.columns.families.commune')} #{object.commune.name_en}" if object.commune.present?
      current_address << object.district_name.split(' / ').last if object.district.present?
      current_address << object.province_name.split(' / ').last if object.province.present?
      current_address << 'Cambodia' if Organization.current.short_name != 'brc'
    end

    current_address.join(', ')
  end

  def drop_down_relation
    locale = self.class.name && self.class.name[/FamilyFields/].present? ? I18n.locale.to_s : params[:locale]
    relationship_values = case locale
    when 'km'
      FamilyMember::KM_RELATIONS
    when 'my'
      FamilyMember::MY_RELATIONS
    else
      FamilyMember::EN_RELATIONS
    end
    [FamilyMember::EN_RELATIONS, relationship_values].transpose
  end

  def family_type_translation(type)
    return if type.nil?
    type = type.downcase.gsub(/\(|\)/, '').gsub(/ \/ |-/, '_').gsub(' ', '_')
    I18n.t("default_family_fields.family_type_list.#{type}")
  end

  def selected_clients
    @family.id ? @clients.where("current_family_id = ?", @family.id).ids : @selected_children
  end

  def children_exist?
    @results && !@results.zero?
  end

  def name_km_en
    @family.name_en? ? "#{@family.name} - #{@family.name_en}" : "#{@family.name}"
  end

  def family_exit_circumstance_value
    @family.status == 'Accepted' ? 'Exited Family' : 'Rejected Referral'
  end

  def render_case_history_family(case_history, case_history_name)
    case case_history_name
    when 'enter_ngos'
      render 'family/enter_ngos/edit_form', family: @family, enter_ngo: case_history
    when 'exit_ngos'
      render 'family/exit_ngos/edit_form', family: @family, exit_ngo: case_history
    end
  end

  def family_case_history_links(case_history, case_history_name)
    case case_history_name
    when 'enrollments'
      link_to edit_family_enrollment_path(@family, case_history, program_stream_id: case_history.program_stream_id) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    when 'leave_programs'
      enrollment = @family.enrollments.find(case_history.enrollment_id)
      link_to edit_family_enrollment_leave_program_path(@family, enrollment, case_history) do
        content_tag :div, class: 'btn btn-outline btn-success btn-xs' do
          fa_icon('pencil')
        end
      end
    end
  end

  def family_translate_exit_reasons(reasons)
    reason_translations = I18n.backend.send(:translations)[:en][:family][:exit_ngos][:edit_form][:exit_reason_options]
    current_translations = I18n.t('family.exit_ngos.edit_form.exit_reason_options')
    reasons.map do |reason|
      current_translations[reason_translations.key(reason)]
    end.join(', ')
  end

  def family_order_case_worker(family)
    family.case_workers.distinct.sort
  end
  def name_km_en
    @family.name_en? ? "#{@family.name} - #{@family.name_en}" : "#{@family.name}"
  end

  def family_header_counter(grid, column)
    count = 0
    if datagrid_column_classes(grid, column) == 'direct_beneficiaries'
      @families.each do |family|
        count += family.member_count
      end
    end

    if count > 0
      class_name = column.name.to_s
      [column.header.truncate(65),
        content_tag(:span, count, class: 'label label-info')
      ].join(' ').html_safe
    else
      column.header.truncate(65)
    end
  end

  def family_saved_search_column_visibility(field_key)
    default_setting(field_key, @default_columns) || params[field_key.to_sym].present? || (@visible_fields && @visible_fields[field_key]).present?
  end

  def skipped_assessment_tool_fields
    if current_setting.hide_family_case_management_tool?
      %i[initial_referral_date follow_up_date referral_source_id referral_source_category_id program_streams quantitative_types quantitative_data]
    else
      []
    end
  end

  def family_hidden_fields_setting
    FieldSetting.without_hidden_fields.where(klass_name: 'family').pluck(:name)
  end

  def list_family_fields
    FieldSetting.where(klass_name: 'family').pluck(:name)
  end

  def family_program_stream_name(object, rule)
    properties_field = 'enrollment_trackings.properties'
    basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    return object if basic_rules.nil?
    basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results      = mapping_form_builder_param_value(basic_rules, rule)
    query_string  = get_query_string(results, rule, properties_field)
    default_value_param = params['all_values']
    if default_value_param
      object
    elsif rule == 'tracking'
      properties_result = object.joins(:enrollment_trackings).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).distinct
    elsif rule == 'active_program_stream'
      mew_query_string = query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")
      program_stream_ids = mew_query_string&.scan(/program_streams\.id = (\d+)/)&.flatten || []
      if program_stream_ids.size >= 2
        sql_partial = mew_query_string.gsub(/program_streams\.id = \d+/, "program_streams.id IN (#{program_stream_ids.join(", ")})")
        # properties_result = object.includes(programmable: :program_streams).where(sql_partial).references(:program_streams).distinct
        properties_result = object.includes(:program_stream)..references(:program_streams).where(sql_partial)
      else
        # properties_result = object.includes(programmable: :program_streams).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).references(:program_streams).distinct
        properties_result = object.includes(:program_stream).references(:program_streams).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} "))
      end
    else
      object
    end
  end

  def has_family_active_program_streams?
    ProgramStream.joins(:families).group("program_streams.id, enrollments.status").having("enrollments.status = 'Active'").any?
  end

end
