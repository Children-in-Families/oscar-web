module FamiliesHelper
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
    {
      date_of_custom_assessments: I18n.t('datagrid.columns.date_of_custom_assessments', assessment: I18n.t('families.show.assessment')),
      all_custom_csi_assessments: I18n.t('datagrid.columns.all_custom_csi_assessments', assessment: I18n.t('families.show.assessment')),
      assessment_completed_date: I18n.t('datagrid.columns.assessment_completed_date', assessment: I18n.t('families.show.assessment'))
    }
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
      contract_date:                            I18n.t('datagrid.columns.families.contract_date'),
      initial_referral_date:                    I18n.t('datagrid.columns.families.initial_referral_date'),
      caregiver_information:                    I18n.t('datagrid.columns.families.caregiver_information'),
      changelog:                                I18n.t('datagrid.columns.families.changelog'),
      case_workers:                             I18n.t('datagrid.columns.families.case_worker_name'),
      case_note_date:                           I18n.t('advanced_search.fields.case_note_date'),
      case_note_type:                           I18n.t('advanced_search.fields.case_note_type'),
      female_children_count:                    I18n.t('datagrid.columns.families.female_children_count'),
      female_adult_count:                       I18n.t('datagrid.columns.families.female_adult_count'),
      male_children_count:                      I18n.t('datagrid.columns.families.male_children_count'),
      clients:                                  I18n.t('datagrid.columns.families.clients'),
      client_id:                                I18n.t('datagrid.columns.families.client'),
      manage:                                   I18n.t('datagrid.columns.families.manage'),
      program_streams:                          I18n.t('datagrid.columns.families.program_streams'),
      program_enrollment_date:                  I18n.t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date:                        I18n.t('datagrid.columns.clients.program_exit_date'),
      direct_beneficiaries:                     I18n.t('datagrid.columns.families.direct_beneficiaries'),
      **additional_columns,
      **family_address_translation
    }
  end

  def family_address_translation
    field_keys = %W(province province_id district district_id commune commune_id village)
    translations = {}
    field_keys.each do |key_translation|
      translations[key_translation.to_sym] = FieldSetting.find_by(name: key_translation).try(:label) || I18n.t("datagrid.columns.clients.#{key_translation}")
      translations["#{key_translation}_".to_sym] = FieldSetting.find_by(name: key_translation).try(:label) || I18n.t("datagrid.columns.families.#{key_translation}")
    end
    translations['province_id'.to_sym] = FieldSetting.find_by(name: 'province_id').try(:label) || I18n.t('datagrid.columns.families.province')
    translations['district_id'.to_sym] = FieldSetting.find_by(name: 'district_id').try(:label) || I18n.t('datagrid.columns.families.district')
    translations['commune_id'.to_sym] = FieldSetting.find_by(name: 'commune_id').try(:label) || I18n.t('datagrid.columns.families.commune')
    translations['village_id'.to_sym] = FieldSetting.find_by(name: 'village_id').try(:label) || I18n.t('datagrid.columns.families.village_id')
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
    if params[:locale] == 'km'
      FamilyMember::KM_RELATIONS
    elsif params[:locale] == 'my'
      FamilyMember::MY_RELATIONS
    else
      FamilyMember::EN_RELATIONS
    end
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
end
