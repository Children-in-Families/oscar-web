module ClientsHelper

  def xeditable? client = nil
    (can?(:manage, client&.object) || can?(:edit, client&.object) || can?(:rud, client&.object)) ? true : false
  end

  def user(user, editable_input=false)
    if !editable_input
      if can? :read, User
        link_to user.name, user_path(user) if user.present?
      elsif user.present?
        user.name
      end
    else
      if user.present? && can?(:read, User)
        link_to user_path(user) do
          fa_icon 'external-link'
        end
      end
    end
  end

  def link_to_client_show(client)
    link_to client.name, client_path(client) if client
  end

  def order_case_worker(client)
    client.users.distinct.sort
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

  def rails_i18n_translations
    # Change slice inputs to adapt your need
    translations = I18n.backend.send(:translations)[I18n.locale].slice(
      :clients,
      :activerecord,
      :default_client_fields
    )

    if current_organization.short_name != 'brc' && I18n.locale.to_s == 'en'
      translations[:clients][:form][:local_given_name] += " #{country_scope_label_translation}" if translations[:clients][:form][:local_given_name].exclude?(country_scope_label_translation)
      translations[:clients][:form][:local_family_name] += " #{country_scope_label_translation}" if translations[:clients][:form][:local_family_name].exclude?(country_scope_label_translation)
    end

    translations
  end

  # Add klass_name_name for readability
  def fields_visibility
    result = field_settings.each_with_object({}) do |field_setting, output|
      output[field_setting.name] = output["#{field_setting.klass_name}_#{field_setting.name}"] = policy(Client).show?(field_setting.name)
    end

    result[:brc_client_address] = result[:client_brc_client_address] = policy(Client).brc_client_address?
    result[:brc_client_other_address] = result[:client_brc_client_other_address] = policy(Client).brc_client_other_address?
    result[:show_legal_doc] = result[:client_show_legal_doc] = policy(Client).show_legal_doc?
    result[:school_information] = result[:client_school_information] = policy(Client).client_school_information?
    result[:stackholder_contacts] = result[:client_stackholder_contacts] = policy(Client).client_stackholder_contacts?

    result
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
      passport_number: t('datagrid.columns.clients.passport_number'),
      national_id_number: t('datagrid.columns.clients.national_id_number'),
      marital_status: t('datagrid.columns.clients.marital_status'),
      nationality: t('datagrid.columns.clients.nationality'),
      ethnicity: t('datagrid.columns.clients.ethnicity'),
      location_of_concern: t('datagrid.columns.clients.location_of_concern'),
      type_of_trafficking: t('datagrid.columns.clients.type_of_trafficking'),
      education_background: t('datagrid.columns.clients.education_background'),
      department: t('datagrid.columns.clients.department'),
      slug:                          t('datagrid.columns.clients.id'),
      kid_id:                        custom_id_translation('custom_id2'),
      code:                          custom_id_translation('custom_id1'),
      age:                           t('datagrid.columns.clients.age'),
      presented_id:                  t('datagrid.columns.clients.presented_id'),
      id_number:                     t('datagrid.columns.clients.id_number'),
      legacy_brcs_id:                t('datagrid.columns.clients.legacy_brcs_id'),
      whatsapp:                      t('datagrid.columns.clients.whatsapp'),
      preferred_language:            t('datagrid.columns.clients.preferred_language'),
      other_phone_number:            t('datagrid.columns.clients.other_phone_number'),
      brsc_branch:                   t('datagrid.columns.clients.brsc_branch'),
      current_island:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_island')),
      current_street:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_street')),
      current_po_box:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_po_box')),
      current_settlement:            t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_settlement')),
      current_resident_own_or_rent:  t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_resident_own_or_rent')),
      current_household_type:        t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_household_type')),
      island2:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.island2')),
      street2:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.street2')),
      po_box2:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.po_box2')),
      settlement2:                   t('datagrid.columns.other_address', column: t('datagrid.columns.clients.settlement2')),
      resident_own_or_rent2:         t('datagrid.columns.other_address', column: t('datagrid.columns.clients.resident_own_or_rent2')),
      household_type2:               t('datagrid.columns.other_address', column: t('datagrid.columns.clients.household_type2')),
      given_name:                    t('datagrid.columns.clients.given_name'),
      national_id: t('datagrid.columns.clients.national_id'),
      birth_cert: t('datagrid.columns.clients.birth_cert'),
      family_book: t('datagrid.columns.clients.family_book'),
      passport: t('datagrid.columns.clients.passport'),
      travel_doc: t('datagrid.columns.clients.travel_doc'),
      referral_doc: t('datagrid.columns.clients.referral_doc'),
      local_consent: t('datagrid.columns.clients.local_consent'),
      police_interview: t('datagrid.columns.clients.police_interview'),
      other_legal_doc: t('datagrid.columns.clients.other_legal_doc'),
      family_name:                   t('datagrid.columns.clients.family_name'),
      local_given_name:              t('datagrid.columns.clients.local_given_name'),
      local_family_name:             t('datagrid.columns.clients.local_family_name'),
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
      date_of_assessments:           t('datagrid.columns.clients.date_of_assessments', assessment: t('clients.show.assessment')),
      date_of_referral:              t('datagrid.columns.clients.date_of_referral'),
      date_of_custom_assessments:    t('datagrid.columns.clients.date_of_custom_assessments', assessment: t('clients.show.assessment')),
      changelog:                     t('datagrid.columns.clients.changelog'),
      live_with:                     t('datagrid.columns.clients.live_with'),
      program_streams:               t('datagrid.columns.clients.program_streams'),
      program_enrollment_date:       t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date:             t('datagrid.columns.clients.program_exit_date'),
      accepted_date:                 t('datagrid.columns.clients.ngo_accepted_date'),
      telephone_number:              t('datagrid.columns.clients.telephone_number'),
      exit_date:                     t('datagrid.columns.clients.ngo_exit_date'),
      created_at:                    t('datagrid.columns.clients.created_at'),
      created_by:                    t('datagrid.columns.clients.created_by'),
      referred_to:                   t('datagrid.columns.clients.referred_to'),
      referred_from:                 t('datagrid.columns.clients.referred_from'),
      referral_source_category_id:   t('datagrid.columns.clients.referral_source_category'),
      type_of_service:               t('datagrid.columns.type_of_service'),
      hotline:                       t('datagrid.columns.calls.hotline'),
      **overdue_translations,
      **Client::HOTLINE_FIELDS.map{ |field| [field.to_sym, I18n.t("datagrid.columns.clients.#{field}")] }.to_h
    }

    Client::STACKHOLDER_CONTACTS_FIELDS.each do |field|
      label_column[field] = t("datagrid.columns.clients.#{field}")
    end

    label_tag "#{column}_", label_column[column.to_sym]
  end

  def overdue_translations
    {
      has_overdue_assessment: I18n.t("datagrid.form.has_overdue_assessment", assessment: I18n.t('clients.show.assessment')),
      has_overdue_forms: I18n.t("datagrid.form.has_overdue_forms"),
      has_overdue_task: I18n.t("datagrid.form.has_overdue_task"),
      no_case_note: I18n.t("datagrid.form.no_case_note")
    }
  end

  def local_name_label(name_type = :local_given_name)
    custom_field = FieldSetting.find_by(name: name_type)
    label = t("datagrid.columns.clients.#{name_type}")
    label = "#{label} #{country_scope_label_translation}" if custom_field.blank? || custom_field.label.blank?
    label
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

    if I18n.locale.to_s == 'km'
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
    current_address << selected_country.titleize
  end

  def concern_merged_address(client)
    current_address = []
    current_address << "#{I18n.t('datagrid.columns.clients.concern_house')} #{client.concern_house}" if client.concern_house.present?
    current_address << "#{I18n.t('datagrid.columns.clients.concern_street')} #{client.concern_street}" if client.concern_street.present?

    if I18n.locale.to_s == 'km'
      current_address << "#{I18n.t('datagrid.columns.clients.concern_village_id')} #{client.concern_village.name_kh}" if client.concern_village.present?
      current_address << "#{I18n.t('datagrid.columns.clients.concern_commune_id')} #{client.concern_commune.name_kh}" if client.concern_commune.present?
      current_address << client.concern_district.name.split(' / ').first if client.concern_district.present?
      current_address << client.concern_province.name.split(' / ').first if client.concern_province.present?
    else
      current_address << "#{I18n.t('datagrid.columns.clients.concern_village_id')} #{client.concern_village.name_en}" if client.concern_village.present?
      current_address << "#{I18n.t('datagrid.columns.clients.concern_commune_id')} #{client.concern_commune.name_en}" if client.concern_commune.present?
      current_address << client.concern_district.name.split(' / ').last if client.concern_district.present?
      current_address << client.concern_province.name.split(' / ').last if client.concern_province.present?
    end
    current_address << selected_country.titleize
  end

  def format_array_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.reject(&:empty?).gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def check_is_array_date?(properties)
    properties.is_a?(Array) && properties.flatten.all?{|value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ? properties.map{|value| date_format(value.to_date) } : properties
  end

  def check_is_string_date?(property)
    (DateTime.strptime(property, '%Y-%m-%d') rescue nil).present? ? property.to_date : property
  end

  def format_properties_value(value)
    value.is_a?(Array) ? check_is_array_date?(value.delete_if(&:empty?).map{|c| c.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')}).join(' , ') : check_is_string_date?(value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"'))
  end

  def field_not_blank?(value)
    value.is_a?(Array) ? value.delete_if(&:empty?).present? : value.present?
  end

  def form_builder_format_key(value)
    value.downcase.parameterize('_')
  end

  def form_builder_format(value)
    value.split('__').last
  end

  def form_builder_format_header(value)
    entities  = { formbuilder: 'Custom form', exitprogram: 'Exit program', tracking: 'Tracking', enrollment: 'Enrollment', enrollmentdate: 'Enrollment', exitprogramdate: 'Exit program' }
    key_word  = value.first
    entity    = entities[key_word.to_sym]
    value     = value - [key_word]
    result    = value << entity
    result.join(' | ')
  end

  def group_entity_by(value)
    value.group_by{ |field| field.split('_').first}
  end

  def format_class_header(value)
    values = value.split('|')
    name   = values.first.strip
    label  = values.last.strip
    keyword = "#{name} #{label}"
    keyword.downcase.parameterize.gsub('-', '__')
  end

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
    when 'uganda'
      current_address = merged_address(client)
    else
      current_address = merged_address(client)
    end
    current_address.compact.join(', ')
  end

  def default_columns_visibility(column)
    label_column = {
      marital_status: t('datagrid.columns.clients.marital_status'),
      nationality: t('datagrid.columns.clients.nationality'),
      ethnicity: t('datagrid.columns.clients.ethnicity'),
      location_of_concern: t('datagrid.columns.clients.location_of_concern'),
      type_of_trafficking: t('datagrid.columns.clients.type_of_trafficking'),
      education_background: t('datagrid.columns.clients.education_background'),
      department: t('datagrid.columns.clients.department'),
      presented_id_:                  t('datagrid.columns.clients.presented_id'),
      id_number_:                     t('datagrid.columns.clients.id_number'),
      legacy_brcs_id_:                t('datagrid.columns.clients.legacy_brcs_id'),
      whatsapp_:                      t('datagrid.columns.clients.whatsapp'),
      preferred_language_:            t('datagrid.columns.clients.preferred_language'),
      other_phone_number_:            t('datagrid.columns.clients.other_phone_number'),
      brsc_branch_:                   t('datagrid.columns.clients.brsc_branch'),
      current_island_:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_island')),
      current_street_:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_street')),
      current_po_box_:                t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_po_box')),
      current_settlement_:            t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_settlement')),
      current_resident_own_or_rent_:  t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_resident_own_or_rent')),
      current_household_type_:        t('datagrid.columns.current_address', column: t('datagrid.columns.clients.current_household_type')),
      island2_:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.island2')),
      street2_:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.street2')),
      po_box2_:                       t('datagrid.columns.other_address', column: t('datagrid.columns.clients.po_box2')),
      settlement2_:                   t('datagrid.columns.other_address', column: t('datagrid.columns.clients.settlement2')),
      resident_own_or_rent2_:         t('datagrid.columns.other_address', column: t('datagrid.columns.clients.resident_own_or_rent2')),
      household_type2_:               t('datagrid.columns.other_address', column: t('datagrid.columns.clients.household_type2')),
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
      local_given_name_: local_name_label,
      local_family_name_: local_name_label(:local_family_name),
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
      code_: custom_id_translation('custom_id1'),
      age_: t('datagrid.columns.clients.age'),
      slug_: t('datagrid.columns.clients.id'),
      kid_id_: custom_id_translation('custom_id2'),
      family_id_: t('datagrid.columns.families.code'),
      case_note_date_: t('datagrid.columns.clients.case_note_date'),
      case_note_type_: t('datagrid.columns.clients.case_note_type'),
      date_of_assessments_: t('datagrid.columns.clients.date_of_assessments', assessment: t('clients.show.assessment')),
      date_of_referral_: t('datagrid.columns.clients.date_of_referral'),
      all_csi_assessments_: t('datagrid.columns.clients.all_csi_assessments'),
      date_of_custom_assessments_: t('datagrid.columns.clients.date_of_custom_assessments', assessment: t('clients.show.assessment')),
      all_custom_csi_assessments_: t('datagrid.columns.clients.all_custom_csi_assessments', assessment: t('clients.show.assessment')),
      manage_: t('datagrid.columns.clients.manage'),
      changelog_: t('datagrid.columns.changelog'),
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
      time_in_ngo_: t('datagrid.columns.clients.time_in_ngo'),
      time_in_cps_: t('datagrid.columns.clients.time_in_cps'),
      referral_source_category_id_: t('datagrid.columns.clients.referral_source_category'),
      type_of_service_: t('datagrid.columns.type_of_service'),
      assessment_completed_date_: t('datagrid.columns.calls.assessment_completed_date', assessment: t('clients.show.assessment')),
      hotline_call_: t('datagrid.columns.calls.hotline_call'),
      **overdue_translations
    }

    (Client::HOTLINE_FIELDS + Call::FIELDS).each do |field_name|
      label_column["#{field_name}_".to_sym] = t("datagrid.columns.clients.#{field_name}")
    end

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
    return object unless params[:client_advanced_search].present? && params[:client_advanced_search][:basic_rules].present?
    @data   = JSON.parse(params[:client_advanced_search][:basic_rules]).with_indifferent_access
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
    properties_field = 'client_enrollment_trackings.properties'
    basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    return object if basic_rules.nil?
    basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results      = mapping_form_builder_param_value(basic_rules, rule)
    query_string  = get_query_string(results, rule, properties_field)
    default_value_param = params['all_values']
    if default_value_param
      object
    elsif rule == 'tracking'
      properties_result = object.joins(:client_enrollment_trackings).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).distinct
    elsif rule == 'active_program_stream'
      mew_query_string = query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")
      program_stream_ids = mew_query_string&.scan(/program_streams\.id = (\d+)/)&.flatten || []
      if program_stream_ids.size >= 2
        sql_partial = mew_query_string.gsub(/program_streams\.id = \d+/, "program_streams.id IN (#{program_stream_ids.join(", ")})")
        properties_result = object.includes(client: :program_streams).where(sql_partial).references(:program_streams).distinct
      else
        properties_result = object.includes(client: :program_streams).where(query_string.reject(&:blank?).join(" #{basic_rules[:condition]} ")).references(:program_streams).distinct
      end
    else
      object
    end
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
    return object unless params[:client_advanced_search].present?
    data    = {}
    rules   = %w( case_note_date case_note_type )
    return object if params[:client_advanced_search][:basic_rules].nil?
    data    = JSON.parse(params[:client_advanced_search][:basic_rules]).with_indifferent_access

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
          object = case_note_query_results(object, case_note_date_query, case_note_type_query).or(object.where(sub_case_note_type_query)).or(object.where(sub_case_note_date_query))
        end
      end
    end
    object.present? ? object : []
  end

  def form_builder_query(object, form_type, field_name, properties_field=nil)
    return object if params['all_values'].present?
    properties_field = properties_field.present? ? properties_field : 'client_enrollment_trackings.properties'

    selected_program_stream = $param_rules['program_selected'].presence ? JSON.parse($param_rules['program_selected']) : []
    basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    results      = mapping_form_builder_param_value(basic_rules, form_type)

    return object if results.flatten.blank?

    query_string  = get_query_string(results, form_type, properties_field)
    if form_type == 'formbuilder'
      properties_result = object.where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    else
      properties_result = object.joins(:client_enrollment).where(client_enrollments: { program_stream_id: selected_program_stream }).where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
    end
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

  def mapping_form_builder_param_value(data, form_type, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_form_builder_param_value(h, form_type, field_name, data_mapping)
      end
      if field_name.nil?
        next if h[:id]&.scan(form_type).blank?
      else
        next if h[:id] != field_name
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def date_filter(object, rule)
    query_array      = []
    sub_query_array  = []
    field_name       = ''
    results          = client_advanced_search_data(object, rule)

    return object if return_default_filter(object, rule, results)

    klass_name  = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', meeting_date: 'case_notes', case_note_type: 'case_notes', created_at: 'assessments' , date_of_referral: 'referrals'}

    if rule == 'case_note_date'
      field_name = 'meeting_date'
    elsif rule.in?(['date_of_assessments', 'date_of_custom_assessments'])
      field_name = 'created_at'
    elsif rule[/^(exitprogramdate)/i].present? || object.class.to_s[/^(leaveprogram)/i]
      klass_name.merge!(rule => 'leave_programs')
      field_name = 'exit_date'
    elsif rule[/^(enrollmentdate)/i].present?
      klass_name.merge!(rule => 'client_enrollments')
      field_name = 'enrollment_date'
    else
      field_name = rule
    end

    relation = rule[/^(enrollmentdate)|^(exitprogramdate)/i] ? "#{klass_name[rule]}.#{field_name}" : "#{klass_name[field_name.to_sym]}.#{field_name}"

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
    return column.header.truncate(65) if grid.class.to_s != 'ClientGrid' || @clients_by_user.blank?
    count = 0
    class_name  = header_classes(grid, column)
    class_name  = class_name == "call-field" ? column.name.to_s : class_name

    if Client::HEADER_COUNTS.include?(class_name) || class_name[/^(enrollmentdate)/i] || class_name[/^(exitprogramdate)/i] || class_name[/^(formbuilder)/i] || class_name[/^(tracking)/i]
      association = "#{class_name}_count"
      klass_name  = { exit_date: 'exit_ngos', accepted_date: 'enter_ngos', case_note_date: 'case_notes', case_note_type: 'case_notes', date_of_assessments: 'assessments', date_of_custom_assessments: 'assessments', formbuilder__Client: 'custom_field_properties' }

      if class_name[/^(exitprogramdate)/i].present? || class_name[/^(leaveprogram)/i]
        klass = 'leave_programs'
      elsif class_name[/^(enrollmentdate)/i].present? || column.header == I18n.t('datagrid.columns.clients.program_streams')
        klass = 'client_enrollments'
      else
        klass = klass_name[class_name.to_sym]
      end

      format_field_value = column.name.to_s.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      fields = column.name.to_s.gsub('&qoute;', '"').split('__')

      if class_name[/^(programexitdate|exitprogramdate)/i].present?
        ids = @clients_by_user.map { |client| client.client_enrollments.inactive.ids }.flatten.uniq
        if $param_rules.nil?
          object = LeaveProgram.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }, leave_programs: { client_enrollment_id: ids })
          count += date_filter(object, class_name).flatten.count
        else
          basic_rules = $param_rules['basic_rules']
          basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results = mapping_exit_program_date_param_value(basic_rules)
          query_string = get_exit_program_date_query_string(results)
          object = LeaveProgram.joins(:program_stream).where(program_streams: { name: column.header.split('|').first.squish }, leave_programs: { client_enrollment_id: ids }).where(query_string)
        end
        count = object.distinct.count
      else
        @clients_by_user.each do |client|
          if class_name == 'case_note_date'
            count += case_note_count(client).count
          elsif class_name == 'case_note_type'
            count += case_note_count(client).count
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
          elsif class_name[/^(date_of_assessments)/i].present?
            if params['all_values'] == class_name
              data_filter = date_filter(client.assessments.defaults, "#{class_name}")
            else
              data_filter = date_filter(client.assessments.defaults, "#{class_name}")
              count += data_filter.flatten.count if data_filter
            end
            count += data_filter ? data_filter.count : assessment_count
          elsif class_name[/^(date_of_custom_assessments)/i].present?
            if params['all_values'] == class_name
              data_filter = date_filter(client.assessments.customs, "#{class_name}")
            else
              data_filter = date_filter(client.assessments.customs, "#{class_name}")
              count += data_filter.flatten.count if data_filter
            end
          elsif class_name[/^(formbuilder)/i].present?
            if fields.last == 'Has This Form'
              count += client.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).count
            else
              properties = form_builder_query(client.custom_field_properties, fields.first, column.name.to_s.gsub('&qoute;', '"'), 'custom_field_properties.properties').properties_by(format_field_value)
              count += property_filter(properties, format_field_value).size
            end
          elsif class_name[/^(tracking)/i]
            ids = client.client_enrollments.ids
            client_enrollment_trackings = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: column.name.to_s.split('__').third }, client_enrollment_trackings: { client_enrollment_id: ids })
            properties = form_builder_query(client_enrollment_trackings, 'tracking', column.name.to_s.gsub('&qoute;', '"')).properties_by(format_field_value)
            count += property_filter(properties, format_field_value).size
          elsif class_name == 'quantitative-type'
            quantitative_type_values = client.quantitative_cases.joins(:quantitative_type).where(quantitative_types: {name: column.header }).pluck(:value)
            quantitative_type_values = property_filter(quantitative_type_values, column.header.split('|').third.try(:strip) || column.header.strip)
            count += quantitative_type_values.count
          elsif class_name == 'type_of_service'
            type_of_services = map_type_of_services(client)
            count += type_of_services.count
          elsif class_name == 'date_of_call'
            count += client.calls.distinct.count
          else
            count += date_filter(client.send(klass.to_sym), class_name).count
          end
        end
      end

      if count > 0 && class_name != 'case_note_type'
        class_name = class_name =~ /^(formbuilder)/i ? column.name.to_s : class_name
        link_all = params['all_values'] != class_name ? button_to('All', ad_search_clients_path, params: params.merge(all_values: class_name), remote: false, form_class: 'all-values') : ''
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

  def case_note_count(client)
    results = []
    @basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
    if @basic_rules.present?
      basic_rules   = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
      results       = mapping_allowed_param_value(basic_rules, ['case_note_date', 'case_note_type'], data_mapping=[])
      query_string  = get_any_query_string(results, 'case_notes')
      client.case_notes.where(query_string)
    else
      client.case_notes
    end
  end

  def case_history_label(value)
    label = case value.class.table_name
            when 'enter_ngos' then t('.accepted_date')
            when 'exit_ngos' then t('.exit_date')
            when 'client_enrollments' then "#{value.program_stream.try(:name)} Entry"
            when 'leave_programs' then "#{value.program_stream.name} Exit"
            when 'clients' then t('.initial_referral_date')
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

  def case_workers_option(client_id, editable_input=false)
    @users.map do |user|
      tasks = user.tasks.incomplete.where(client_id: client_id)
      if !editable_input
        if tasks.any?
          [user.name, user.id, { locked: 'locked'} ]
        else
          [user.name, user.id]
        end
      else
        if tasks.any?
          { text: user.name, value: user.id, locked: 'locked' }
        else
          { text: user.name, value: user.id }
        end
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
    return '' if Setting.first.try(:country_name) == 'nepal'
    if I18n.locale.to_s == 'en'
      country_name = Setting.first.try(:country_name)
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

  def date_condition_filter(rule, properties)
    if rule && properties.present?
      case rule[:operator]
      when 'equal'
        properties = properties.select{|value| value.to_date == rule[:value].to_date  }
      when 'not_equal'
        properties = properties.select{|value| value.to_date != rule[:value].to_date  }
      when 'less'
        properties = properties.select{|value| value.to_date < rule[:value].to_date  }
      when 'less_or_equal'
        properties = properties.select{|value| value.to_date <= rule[:value].to_date  }
      when 'greater'
        properties = properties.select{|value| value.to_date > rule[:value].to_date  }
      when 'greater_or_equal'
        properties = properties.select{|value| value.to_date >= rule[:value].to_date  }
      when 'is_empty'
        properties = []
      when 'is_not_empty'
        properties
      when 'between'
        properties = properties.is_a?(Array) ? properties.select { |value| value.to_date >= rule[:value].first.to_date && value.to_date <= rule[:value].last.to_date  } : [properties].flatten.compact
      end
    end
    properties || []
  end

  def property_filter(properties, field_name)
    results = []
    rule = get_rule(params, field_name)
    if rule.presence && rule.dig(:type) == 'date'
      results = date_condition_filter(rule, properties)
    elsif rule.presence && rule[:input] == 'select'
      results = select_condition_filter(rule, properties.flatten)
    elsif rule.presence
      results = string_condition_filter(rule, properties.flatten)
    end
    results = results.presence ? results : properties
  end

  def string_condition_filter(rule, properties)
    case rule[:operator]
    when 'equal'
      properties = rule[:type] != 'integer' ? properties.select{|value| value == rule[:value].strip  } : properties.select{|value| value.to_i == rule[:value]  }
    when 'not_equal'
      properties = rule[:type] != 'integer' ? properties.select{|value| value != rule[:value].strip  } : properties.select{|value| value.to_i != rule[:value]  }
    when 'less'
      properties = rule[:type] != 'integer' ? properties.select{|value| value < rule[:value].strip  } : properties.select{|value| value.to_i < rule[:value]  }
    when 'less_or_equal'
      properties = rule[:type] != 'integer' ? properties.select{|value| value <= rule[:value].strip  } : properties.select{|value| value.to_i <= rule[:value]  }
    when 'greater'
      properties = rule[:type] != 'integer' ? properties.select{|value| value > rule[:value].strip  } : properties.select{|value| value.to_i > rule[:value]  }
    when 'greater_or_equal'
      properties = rule[:type] != 'integer' ? properties.select{|value| value >= rule[:value].strip  } : properties.select{|value| value.to_i >= rule[:value]  }
    when 'contains'
      properties.include?(rule[:value].strip)
    when 'not_contains'
      properties.exclude?(rule[:value].strip)
    when 'is_empty'
      properties = []
    when 'is_not_empty'
      properties
    when 'between'
      properties = rule[:type] != 'integer' ? properties.select{|value| value.to_i >= rule[:value].first.strip && value.to_i <= rule[:value].last.strip  } : properties.select{|value| value.to_i >= rule[:value].first && value.to_i <= rule[:value].last  }
    end
    properties
  end

  def select_condition_filter(rule, properties)
    case rule[:operator]
    when 'equal'
      properties = properties.select do |value|
        if rule[:data][:values].is_a?(Hash)
          value == rule[:data][:values][rule[:value].to_sym]
        else
          value == rule[:data][:values].map{ |hash| hash[rule[:value].to_sym] }.compact.first
        end
      end
    when 'not_equal'
      properties = properties.select{|value| value != rule[:data][:values].map{|hash| hash[rule[:value].to_sym] }.compact.first  }
    when 'is_empty'
      properties = []
    when 'is_not_empty'
      properties
    end
    properties
  end

  def get_rule(params, field)
    return unless params.dig('client_advanced_search').present? && params.dig('client_advanced_search', 'basic_rules').present?
    base_rules = eval params.dig('client_advanced_search', 'basic_rules')
    rules = base_rules.dig(:rules) if base_rules.presence

    index = find_rules_index(rules, field) if rules.presence

    rule  = rules[index] if index.presence
  end

  def find_rules_index(rules, field)
    index = rules.index do |rule|
      if rule.has_key?(:rules)
        find_rules_index(rule[:rules], field)
      else
        rule[:field].strip == field
      end
    end
  end

  def referral_source_name(referral_source)
    if I18n.locale == :km
      referral_source.map{|ref| [ref.name, ref.id] }
    else
      referral_source.map do |ref|
        if ref.name_en.blank?
          [ref.name, ref.id]
        else
          [ref.name_en, ref.id]
        end
      end
    end
  end

  def group_client_associations
    [*@assessments, *@case_notes, *@tasks, *@client_enrollment_leave_programs, *@client_enrollment_trackings, *@client_enrollments, *@case_histories, *@custom_field_properties, *@calls].group_by do |association|
      class_name = association.class.name.downcase
      if class_name == 'clientenrollment' || class_name == 'leaveprogram' || class_name == 'casenote'
        created_date = association.created_at
        date_field = if class_name == 'clientenrollment'
          association.enrollment_date
        elsif class_name == 'leaveprogram'
          association.exit_date
        elsif class_name == 'casenote'
          association.meeting_date
        elsif class_name == 'call'
          association.date_of_call
        end
        distance_between_dates = (date_field.to_date - created_date.to_date).to_i
        created_date + distance_between_dates.day
      else
        association.created_at
      end
    end.sort_by{|k, v| k }.reverse.to_h
  end

  def referral_source_category(id)
    if I18n.locale == :km
      ReferralSource.find_by(id: id).try(:name)
    else
      ReferralSource.find_by(id: id).try(:name_en)
    end
  end

  def translate_exit_reasons(reasons)
    reason_translations = I18n.backend.send(:translations)[:en][:client][:exit_ngos][:edit_form][:exit_reason_options]
    current_translations = I18n.t('client.exit_ngos.edit_form.exit_reason_options')
    reasons.map do |reason|
      current_translations[reason_translations.key(reason)]
    end.join(', ')
  end

  def custom_id_translation(type)
    if I18n.locale != :km || Setting.first.country_name != 'lesotho'
      if type == 'custom_id1'
        Setting.first.custom_id1_latin.present? ? Setting.first.custom_id1_latin : I18n.t("#{I18n.locale.to_s}.clients.other_detail.custom_id_number1")
      else
        Setting.first.custom_id2_latin.present? ? Setting.first.custom_id2_latin : t('.custom_id_number2')
      end
    else
      if type == 'custom_id1'
        Setting.first.custom_id1_local.present? ? Setting.first.custom_id1_local : t('.custom_id_number1')
      else
        Setting.first.custom_id2_local.present? ? Setting.first.custom_id2_local : t('.custom_id_number2')
      end
    end
  end

  def client_donors
    @client.donors.distinct
  end

  def initial_referral_date_picker_format(client)
    "#{client.initial_referral_date&.year}, #{client.initial_referral_date&.month}, #{@client.initial_referral_date&.day}"
  end

  def get_address_json
    Client::BRC_ADDRESS.zip(Client::BRC_ADDRESS).to_h.to_json
  end

  def get_quantitative_types
    if current_organization.short_name != 'brc'
      QuantitativeType.all
    else
      QuantitativeType.unscoped.order("substring(quantitative_types.name, '^[0-9]+')::int, substring(quantitative_types.name, '[^0-9]*$')")
    end
  end

  def get_address(address_name)
    @client.public_send("#{address_name}") ? [@client.public_send("#{address_name}").slice('id', 'name')] : []
  end

  def saved_search_column_visibility(field_key)
    default_setting(field_key, @client_default_columns) || params[field_key.to_sym].present? || (@visible_fields && @visible_fields[field_key]).present?
  end
end
