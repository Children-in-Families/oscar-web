module ClientsHelper
  def user(user)
    if can? :read, User
      link_to user.name, user_path(user) if user.present?
    elsif user.present?
      user.name
    end
  end

  def order_case_worker(client)
    client.users.order("lower(first_name)", "lower(last_name)")
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
      case_type:                     t('datagrid.columns.clients.case_type'),
      age:                           t('datagrid.columns.clients.age'),
      given_name:                    t('datagrid.columns.clients.given_name'),
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
      any_assessments:               t('datagrid.columns.clients.assessments'),
      case_note_date:                t('datagrid.columns.clients.case_note_date'),
      case_note_type:                t('datagrid.columns.clients.case_note_type'),
      date_of_assessments:           t('datagrid.columns.clients.date_of_assessments'),
      donor:                         t('datagrid.columns.clients.donor'),
      changelog:                     t('datagrid.columns.clients.changelog'),
      live_with:                     t('datagrid.columns.clients.live_with'),
      # id_poor:                       t('datagrid.columns.clients.id_poor'),
      program_streams:               t('datagrid.columns.clients.program_streams'),
      program_enrollment_date:       t('datagrid.columns.clients.program_enrollment_date'),
      program_exit_date:             t('datagrid.columns.clients.program_exit_date'),
      accepted_date:                 t('datagrid.columns.clients.ngo_accepted_date'),
      telephone_number:              t('datagrid.columns.clients.telephone_number'),
      exit_date:                     t('datagrid.columns.clients.ngo_exit_date')
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def case_button(type)
    link_to new_client_case_path(@client, case_type: type) do
      content_tag(:span, '') do
        content_tag(:span, t(".add_#{type.downcase}_btn"), class: 'text-success')
      end
    end
  end

  def ec_manageable
    current_user.admin? || current_user.case_worker? || current_user.ec_manager? || current_user.manager?
  end

  def fc_manageable
    current_user.admin? || current_user.case_worker? || current_user.fc_manager? || current_user.manager?
  end

  def kc_manageable
    current_user.admin? || current_user.case_worker? || current_user.kc_manager? || current_user.manager?
  end

  def can_read_client_progress_note?
    @client.able? && (current_user.case_worker? || current_user.able_manager? || current_user.admin? || current_user.fc_manager? || current_user.manager? || current_user.kc_manager? || current_user.strategic_overviewer?)
  end

  def disable_case_histories?
    'disabled' if current_user.able_manager?
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
    current_address << "#{I18n.t('datagrid.columns.clients.village')} #{client.village}" if client.village.present?
    current_address << "#{I18n.t('datagrid.columns.clients.commune')} #{client.commune}" if client.commune.present?
    if locale == :km
      current_address << client.district.name.split(' / ').first if client.district.present?
      current_address << client.province.name.split(' / ').first if client.province.present?
    else
      current_address << client.district.name.split(' / ').last if client.district.present?
      current_address << client.province.name.split(' / ').last if client.province.present?
    end
    country = params[:country].present? ? I18n.t("datagrid.columns.clients.#{params[:country]}") : I18n.t('datagrid.columns.clients.cambodia')
    current_address << country
    current_address.compact.join(', ')
  end

  def format_array_value(value)
    value.is_a?(Array) ? value.reject(&:empty?).gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"').join(' , ') : value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')
  end

  def format_properties_value(value)
    value.is_a?(Array) ? value.delete_if(&:empty?).map{|c| c.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')}.join(' , ') : value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').gsub('&qoute;', '"')
  end

  def field_not_blank?(value)
    value.is_a?(Array) ? value.delete_if(&:empty?).present? : value.present?
  end

  def form_builder_format_key(value)
    value.downcase.parameterize('_')
  end

  def form_builder_format(value)
    value.split('_').last
  end

  def form_builder_format_header(value)
    entities  = { formbuilder: 'Custom form', exitprogram: 'Exit program', tracking: 'Tracking', enrollment: 'Enrollment', enrollmentdate: 'Enrollment', programexitdate: 'Exit program' }
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
    keyword.downcase.parameterize('_')
  end

  def field_not_render(field)
    field.split('_').first
  end

  def all_csi_assessment_lists(object)
    content_tag(:ul) do
      if params[:data] == 'recent'
        object.assessments.latest_record.try(:basic_info)
      else
        object.assessments.each do |assessment|
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

  def enable_assessment_setting?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
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
      local_given_name_: t('datagrid.columns.clients.local_given_name'),
      local_family_name_: t('datagrid.columns.clients.local_family_name'),
      gender_: t('datagrid.columns.clients.gender'),
      date_of_birth_: t('datagrid.columns.clients.date_of_birth'),
      status_: t('datagrid.columns.clients.status'),
      case_type_: t('datagrid.columns.cases.case_type'),
      birth_province_id_: t('datagrid.columns.clients.birth_province'),
      initial_referral_date_: t('datagrid.columns.clients.initial_referral_date'),
      referral_phone_: t('datagrid.columns.clients.referral_phone'),
      received_by_id_: t('datagrid.columns.clients.received_by'),
      referral_source_id_: t('datagrid.columns.clients.referral_phone'),
      followed_up_by_id_: t('datagrid.columns.clients.follow_up_by'),
      follow_up_date_: t('datagrid.columns.clients.follow_up_date'),
      agencies_name_: t('datagrid.columns.clients.agencies_involved'),
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
      case_start_date_: t('datagrid.columns.clients.placements.start_date'),
      carer_names_: t('datagrid.columns.clients.placements.carer_names'),
      carer_address_: t('datagrid.columns.clients.placements.carer_address'),
      carer_phone_number_: t('datagrid.columns.clients.placements.carer_phone_number'),
      support_amount_: t('datagrid.columns.clients.placements.support_amount'),
      support_note_: t('datagrid.columns.clients.placements.support_note'),
      form_title_: t('datagrid.columns.clients.form_title'),
      family_preservation_: t('datagrid.columns.families.family_preservation'),
      family_: t('datagrid.columns.clients.placements.family'),
      partner_: t('datagrid.columns.partners.partner'),
      code_: t('datagrid.columns.clients.code'),
      age_: t('datagrid.columns.clients.age'),
      slug_: t('datagrid.columns.clients.id'),
      kid_id_: t('datagrid.columns.clients.kid_id'),
      family_id_: t('datagrid.columns.families.code'),
      case_note_date_: t('datagrid.columns.clients.case_note_date'),
      case_note_type_: t('datagrid.columns.clients.case_note_type'),
      date_of_assessments_: t('datagrid.columns.clients.date_of_assessments'),
      all_csi_assessments_: t('datagrid.columns.clients.all_csi_assessments'),
      donor_: t('datagrid.columns.clients.donor'),
      manage_: t('datagrid.columns.clients.manage'),
      changelog_: t('datagrid.columns.changelog'),
      telephone_number_: t('datagrid.columns.clients.telephone_number')
    }
    Domain.order_by_identity.each do |domain|
      identity = domain.identity
      field = domain.convert_identity
      label_column = label_column.merge!("#{field}_": identity)
    end
    label_column[column.to_sym]
  end
end
