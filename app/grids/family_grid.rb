class FamilyGrid < BaseGrid
  include ClientsHelper

  attr_accessor :dynamic_columns

  scope do
    Family.includes({cases: [:client]}, :village, :commune, :district, :province).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.families.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:name_en, :string, header: -> { I18n.t('datagrid.columns.families.name_en') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.families.id') })

  filter(:code, :string, header: -> { I18n.t('datagrid.columns.families.code') }) do |value, scope|
    scope.family_id_like(value)
  end

  filter(:family_type, :enum, select: :mapping_family_type_translation, header: -> { I18n.t('datagrid.columns.families.family_type') }) do |value, scope|
    scope.by_family_type(value)
  end

  filter(:status, :enum, select: Family::STATUSES, header: -> { I18n.t('datagrid.columns.families.status') }) do |value, scope|
    scope.by_status(value)
  end

  filter(:gender, :enum, select: :gender_options, header: -> { I18n.t('activerecord.attributes.family_member.gender') }) do |value, scope|
    scope.joins(:family_members).where("family_members.gender = ?", value)
  end

  filter(:date_of_birth, :date, header: -> { I18n.t('datagrid.columns.families.date_of_birth') }) do |value, scope|
    scope.joins(:family_members).where("DATE(family_members.date_of_birth) = ?", value)
  end

  filter(:case_history, :string, header: -> { I18n.t('datagrid.columns.families.case_history') }) do |value, scope|
    scope.case_history_like(value)
  end


  filter(:significant_family_member_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.significant_family_member_count') })

  filter(:female_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.female_children_count') })

  filter(:male_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.male_children_count') })

  filter(:received_by_id, :enum, select: :province_options, header: -> { I18n.t('datagrid.columns.families.received_by_id') })

  filter(:province_id, :enum, select: :province_options, header: -> { I18n.t('datagrid.columns.families.province') })

  filter(:district_id, :enum, select: :district_options, header: -> { I18n.t('datagrid.columns.families.district') })

  filter(:commune_id, :enum, select: :commune_options, header: -> { I18n.t('datagrid.columns.families.commune') })

  filter(:village_id, :enum, select: :village_options, header: -> { I18n.t('datagrid.columns.families.village') })

  filter(:street, :string, header: -> { I18n.t('datagrid.columns.families.street') }) do |value, scope|
    scope.street_like(value)
  end

  filter(:house, :string, header: -> { I18n.t('datagrid.columns.families.house') }) do |value, scope|
    scope.house_like(value)
  end

  filter(:phone_number, :string, header: -> { I18n.t('datagrid.columns.families.phone_number') })

  def mapping_family_type_translation
    [I18n.t('default_family_fields.family_type_list').values, I18n.backend.send(:translations)[:en][:default_family_fields][:family_type_list].values].transpose
  end

  def commune_options
    Family.joins(:commune).map{|f| [f.commune.code_format, f.commune_id]}.uniq
  end

  def village_options
    Family.joins(:village).map{|f| [f.village.code_format, f.village_id]}.uniq
  end

  def province_options
    Family.province_are
  end

  def district_options
    Family.joins(:district).pluck('districts.name', 'districts.id').uniq
  end

  def gender_options
    FamilyMember.gender.values.map{ |value| [I18n.t("datagrid.columns.families.gender_list.#{value.gsub('other', 'other_gender')}"), value] }
  end

  def family_id_poor
    Family::ID_POOR
  end

  filter(:id_poor, :enum, select: :family_id_poor, header: -> { I18n.t('datagrid.columns.families.id_poor') })

  filter(:dependable_income, :xboolean, header: -> { I18n.t('datagrid.columns.families.dependable_income') }) do |value, scope|
    value ? scope.where(dependable_income: true) : scope.where(dependable_income: false)
  end

  filter(:female_adult_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.female_adult_count') })

  filter(:male_adult_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.male_adult_count') })

  filter(:household_income, :float, range: true, header: -> { I18n.t('datagrid.columns.families.household_income') })

  filter(:contract_date, :date, header: -> { I18n.t('datagrid.columns.families.contract_date') })

  filter(:initial_referral_date, :date, header: -> { I18n.t('datagrid.columns.families.initial_referral_date') })

  filter(:follow_up_date, :date, header: -> { I18n.t('datagrid.columns.families.follow_up_date') })

  filter(:caregiver_information, :string, header: -> { I18n.t('datagrid.columns.families.caregiver_information') }) do |value, scope|
    scope.caregiver_information_like(value)
  end

  filter(:referral_source_id, :enum, select: :referral_source_options, header: -> { I18n.t('datagrid.columns.families.referral_source_id') })
  filter(:referral_source_category_id, :enum, select: :referral_source_category_options, header: -> { I18n.t('datagrid.columns.families.referral_source_category_id') })

  def referral_source_options
    current_user.present? ? Family.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).referral_source_is : Family.referral_source_is
  end

  def referral_source_category_options
    if I18n.locale == :km
      ReferralSource.where(id: Family.pluck(:referral_source_category_id).compact).pluck(:name, :id)
    else
      ReferralSource.where(id: Family.pluck(:referral_source_category_id).compact).pluck(:name_en, :id)
    end
  end

  filter(:program_streams, :enum, multiple: true, select: :program_stream_options, header: -> { I18n.t('datagrid.columns.families.program_streams') }) do |name, scope|
    program_stream_ids = ProgramStream.name_like(name).ids
    ids = Family.joins(:enrollments).where(enrollments: { program_stream_id: program_stream_ids } ).pluck(:id).uniq
    scope.where(id: ids)
  end

  def program_stream_options
    ProgramStream.joins(:enrollments).complete.ordered.pluck(:name).uniq
  end

  def quantitative_type_options
    QuantitativeType.all.map{ |t| [t.name, t.id] }
  end

  filter(:quantitative_types, :enum, select: :quantitative_type_options, header: -> { I18n.t('datagrid.columns.clients.quantitative_types') }) do |value, scope|
    ids = Family.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  def quantitative_cases
    qType.present? ? QuantitativeType.find(qType.to_i).quantitative_cases.map{ |t| [t.value, t.id] } : QuantitativeCase.all.map{ |t| [t.value, t.id] }
  end

  filter(:quantitative_data, :enum, select: :quantitative_cases, header: -> { I18n.t('datagrid.columns.clients.quantitative_case_values') }) do |value, scope|
    ids = Family.joins(:quantitative_cases).where(quantitative_cases: { id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  def filer_section(filter_name)
    {
      street: :address,
      house: :address,
      dependable_income: :general,
      female_adult_count: :aggregrate,
      male_adult_count: :aggregrate,
      household_income: :general,
      follow_up_date: :general,
      contract_date: :general,
      caregiver_information: :general,
      id: :general,
      id_poor: :general,
      code: :general,
      name: :general,
      name_en: :general,
      phone_number: :general,
      family_type: :aggregrate,
      status: :general,
      gender: :general,
      date_of_birth: :general,
      case_history: :general,
      member_count: :aggregrate,
      cases: :aggregrate,
      case_workers: :aggregrate,
      significant_family_member_count: :aggregrate,
      female_children_count: :aggregrate,
      male_children_count: :aggregrate,
      village_id: :address,
      commune_id: :address,
      district_id: :address,
      province_id: :address,
      manage: :aggregrate,
      changelo: :aggregrate,
      active_families: :general
    }[filter_name]
  end

  column(:id, header: -> { I18n.t('datagrid.columns.families.id') })

  column(:code, header: -> { I18n.t('datagrid.columns.families.code') })

  column(:name, html: true, order: 'LOWER(name)', header: -> { I18n.t('datagrid.columns.families.name') }) do |object|
    link_to entity_name(object), family_path(object)
  end

  column(:name_en, order: 'LOWER(name_en)', header: -> { I18n.t('datagrid.columns.families.name_en') }) do |object|

    format(object.name_en) do |value|
      link_to value, family_path(object) if value.present?
    end
  end

  column(:name, html: false, header: -> { I18n.t('datagrid.columns.families.name') })

  column(:family_type, header: -> { I18n.t('datagrid.columns.families.family_type') }) do |object|
    object.family_type
  end

  column(:status, header: -> { I18n.t('datagrid.columns.families.status') }) do |object|
    object.status
  end

  column(:gender, html: true, header: -> { I18n.t('activerecord.attributes.family_member.gender') }) do |object|
    content_tag :ul, class: '' do
      object.family_members.map(&:gender).each do |gender|
        next unless gender
        concat(content_tag(:li, I18n.t("datagrid.columns.families.gender_list.#{gender.gsub('other', 'other_gender')}")))
      end
    end
  end

  column(:date_of_birth, html: true, header: -> { I18n.t('datagrid.columns.families.date_of_birth') }) do |object|
    content_tag :ul do
      object.family_members.map(&:date_of_birth).compact.each do |dob|
        concat(content_tag(:li, dob&.strftime("%d %B %Y")))
      end
    end
  end

  column(:gender, html: false, header: -> { I18n.t('activerecord.attributes.family_member.gender') }) do |object|
    object.family_members.map(&:gender).compact.join(", ")
  end

  column(:date_of_birth, html: false, header: -> { I18n.t('datagrid.columns.families.date_of_birth') }) do |object|
    object.family_members.map{ |member| member.date_of_birth&.strftime("%d %B %Y") }.compact.join(", ")
  end

  column(:id_poor, header: -> { I18n.t('datagrid.columns.families.id_poor') })

  column(:case_history, html: true, header: -> { I18n.t('datagrid.columns.families.case_history') }) do |object|
    family_case_history(object)
  end

  column(:case_history, html: false, header: -> { I18n.t('datagrid.columns.families.case_history') })

  column(:member_count, html: true, header: -> { I18n.t('datagrid.columns.families.member_count') }, order: ('families.female_children_count, families.male_children_count, families.female_adult_count, families.male_adult_count')) do |object|
    render partial: 'families/members', locals: { object: object }
  end

  column(:caregiver_information, order: 'LOWER(caregiver_information)', header: -> { I18n.t('datagrid.columns.families.caregiver_information') })

  column(:household_income, header: -> { I18n.t('datagrid.columns.families.household_income') })

  column(:dependable_income, header: -> { I18n.t('datagrid.columns.families.dependable_income') }) do |object|
    object.dependable_income ? 'Yes' : 'No'
  end

  column(:cases, html: true, order: false, header: -> { I18n.t('datagrid.columns.families.clients') }) do |object|
    render partial: 'families/clients', locals: { object: object }
  end

  column(:case_workers, header: -> { I18n.t('datagrid.columns.families.case_worker_name') }) do |object|
    case_workers = object.case_workers
    format(case_workers.map(&:name).join(', ')) do |_|
      render partial: 'families/case_workers', locals: { case_workers: case_workers }
    end
  end

  column(:significant_family_member_count, header: -> { I18n.t('datagrid.columns.families.significant_family_member_count') })
  column(:female_children_count, header: -> { I18n.t('datagrid.columns.families.female_children_count') })
  column(:male_children_count, header: -> { I18n.t('datagrid.columns.families.male_children_count') })
  column(:female_adult_count, header: -> { I18n.t('datagrid.columns.families.female_adult_count') })
  column(:male_adult_count, header: -> { I18n.t('datagrid.columns.families.male_adult_count') })

  date_column(:contract_date, html: true, header: -> { I18n.t('datagrid.columns.families.contract_date') })
  date_column(:initial_referral_date, header: -> { I18n.t('datagrid.columns.families.initial_referral_date') })
  date_column(:follow_up_date, header: -> { I18n.t('datagrid.columns.families.follow_up_date') })

  column(:contract_date, html: false, header: -> { I18n.t('datagrid.columns.families.contract_date') }) do |object|
    object.contract_date.present? ? object.contract_date : ''
  end

  column(:received_by_id, header: -> { I18n.t('datagrid.columns.families.received_by_id') }) do |object|
    format(object.received_by&.name) do |user_name|
      if can? :read, User
        link_to user_name, user_path(object.received_by) if object.received_by.present?
      elsif user_name.present?
        user_name
      end
    end
  end

  column(:followed_up_by_id, header: -> { I18n.t('datagrid.columns.families.followed_up_by_id') }) do |object|
    format(object.followed_up_by&.name) do |user_name|
      if can? :read, User
        link_to user_name, user_path(object.followed_up_by) if object.followed_up_by.present?
      elsif user_name.present?
        user_name
      end
    end
  end

  column(:referral_source_id, header: -> { I18n.t('datagrid.columns.families.referral_source_id') }) do |object|
    format(object.referral_source&.name) do |referral_source_name|
      referral_source_name
    end
  end

  column(:referral_source_category_id, header: -> { I18n.t('datagrid.columns.families.referral_source_category_id') }) do |object|
    if I18n.locale == :km
      referral_source_name = ReferralSource.find_by(id: object.referral_source_category_id).try(:name)
    else
      referral_source_name = ReferralSource.find_by(id: object.referral_source_category_id).try(:name_en)
    end
    format(referral_source_name) do |referral_source_name|
      referral_source_name
    end
  end

  column(:house, header: -> { I18n.t('datagrid.columns.families.house') })
  column(:phone_number, header: -> { I18n.t('datagrid.columns.families.phone_number') })
  column(:street, header: -> { I18n.t('datagrid.columns.families.street') })

  column(:village_id, order: 'villages.name_kh', header: -> { I18n.t('datagrid.columns.families.village') }) do |object|
    format(object.village.try(:code_format)) { |value| value }
  end

  column(:commune_id, order: 'communes.name_kh', header: -> { I18n.t('datagrid.columns.families.commune') }) do |object|
    format(object.commune.try(:name)) { |value| value }
  end

  column(:district_id, order: 'districts.name', header: -> { I18n.t('datagrid.columns.families.district') }) do |object|
    format(object.district_name) { |value| value }
  end

  column(:province_id, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.families.province') }) do |object|
    format(object.province_name) { |value| value }
  end

  column(:cases, header: -> { I18n.t('datagrid.columns.families.clients') }, html: false) do |object|
    Client.where(id: object.children).map(&:name).join(', ')
  end

  column(:clients, header: -> { I18n.t('datagrid.columns.families.clients') }) do |object|
    clients = object.family_members.joins(:client).map(&:client)
    format(clients.map(&:name).join(', ')) do |_|
      family_clients_list(object)
    end
  end

  column(:direct_beneficiaries, header: -> { I18n.t('datagrid.columns.families.direct_beneficiaries') }) do |object|
    object.member_count
  end

  column(:care_plan_completed_date, header: -> { I18n.t('datagrid.columns.families.care_plan_completed_date') }, html: true) do |object|
    render partial: 'shared/care_plans/care_plans', locals: { object: object.care_plans }
  end

  column(:care_plan_count, header: -> { I18n.t('datagrid.columns.families.care_plan_count') }, html: true, class: 'hide') do |object|
  end

  column(:case_note_date, header: -> { I18n.t('datagrid.columns.families.case_note_date')}, html: true) do |object|
    render partial: 'clients/case_note_date', locals: { object: object }
  end

  column(:case_note_type, header: -> { I18n.t('datagrid.columns.families.case_note_type')}, html: true) do |object|
    render partial: 'clients/case_note_type', locals: { object: object }
  end

  column(:program_streams, html: true, order: false, header: -> { I18n.t('datagrid.columns.families.program_streams') }) do |object, a, b, c|
    family_enrollments = family_program_stream_name(object.enrollments.active, 'active_program_stream')
    render partial: 'families/active_family_enrollments', locals: { active_programs: family_enrollments }
  end

  dynamic do
    next unless dynamic_columns.present?
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }) do |object|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        if fields.first == 'formbuilder'
          if fields.last == 'Has This Form'
            properties = [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).count]
          else
            properties_field = 'custom_field_properties.properties'
            # format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')

            basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
            basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
            results      = mapping_form_builder_param_value(basic_rules, 'formbuilder')

            query_string = get_query_string(results, 'formbuilder', properties_field)
            sql          = query_string.reverse.reject(&:blank?).map{|sql| "(#{sql})" }.join(" AND ")

            properties   = object.custom_field_properties.joins(:custom_field).where(sql).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).properties_by(format_field_value)
          end
        elsif fields.first == 'enrollmentdate'
          properties = date_filter(object.enrollments.joins(:program_stream).where(program_streams: { name: fields.second }), fields.join('__')).map{|date| date_format(date.enrollment_date) }
        elsif fields.first == 'enrollment'
          properties = object.enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).properties_by(format_field_value)
        elsif fields.first == 'tracking'
          ids = object.enrollments.ids
          enrollment_trackings = EnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, enrollment_trackings: { enrollment_id: ids })
          properties = family_form_builder_query(enrollment_trackings, fields.first, column_builder[:id].gsub('&qoute;', '"')).properties_by(format_field_value, enrollment_trackings)
        elsif fields.first == 'exitprogramdate'
          ids = object.enrollments.inactive.ids
          properties = date_filter(LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { enrollment_id: ids }), fields.join('__')).map{|date| date_format(date.exit_date) }
        elsif fields.first == 'exitprogram'
          ids = object.enrollments.inactive.ids
          if $param_rules.nil?
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { enrollment_id: ids }).properties_by(format_field_value)
          else
            basic_rules = $param_rules['basic_rules']
            basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
            results = mapping_exit_program_date_param_value(basic_rules)
            query_string = get_exit_program_date_query_string(results)
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { enrollment_id: ids }).where(query_string).properties_by(format_field_value)
          end
        end

        format(properties.join(", ")) do |values|
          render partial: 'shared/form_builder_dynamic/properties_value', locals: { properties:  values.split(',') } if values.present?
        end
      end

    end
  end

  dynamic do
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?
    quantitative_types = QuantitativeType.joins(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', "%family%").distinct
    quantitative_types.each do |quantitative_type|
      if current_user.nil? || quantitative_type_readable_ids.include?(quantitative_type.id)
        column(quantitative_type.name.to_sym, class: 'quantitative-type', header: -> { quantitative_type.name }, html: true) do |object|
          quantitative_type_values = object.quantitative_cases.where(quantitative_type_id: quantitative_type.id).pluck(:value)
          rule = get_rule(params, quantitative_type.name.squish)
          if rule.presence && rule.dig(:type) == 'date'
            quantitative_type_values = date_condition_filter(rule, quantitative_type_values)
          elsif rule.present?
            if rule.dig(:input) == 'select'
              quantitative_type_values = select_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            else
              quantitative_type_values = string_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            end
          end
          quantitative_type_values.join(', ')
        end
      end
    end
  end

  dynamic do
    if !Setting.first.hide_family_case_management_tool?
      column(:all_custom_csi_assessments, header: -> { I18n.t('datagrid.columns.all_custom_csi_assessments', assessment: t('families.show.assessment')) }, html: true) do |object|
        render partial: 'families/all_csi_assessments', locals: { object: object.assessments.customs }
      end

      Domain.family_custom_csi_domains.order_by_identity.each do |domain|
        domain_id = domain.id
        identity = domain.identity
        column("#{domain.convert_custom_identity}".to_sym, class: 'domain-scores', header: identity, html: true) do |family|
          assessments = map_assessment_and_score(family, identity, domain_id)
          assessment_domains = assessments.includes(:assessment_domains).map { |assessment| assessment.assessment_domains.joins(:domain).where(domains: { id: domain_id }) }.flatten.uniq
          render  partial: 'families/list_domain_score', locals: { assessment_domains: assessment_domains }
        end
      end
    end
  end

  column(:assessment_completed_date, header: -> { I18n.t('datagrid.columns.assessment_completed_date', assessment: I18n.t('families.show.assessment')) }, html: true) do |object|
    assessments = map_assessment_and_score(object, '', nil)
    render partial: 'families/assessments', locals: { object: assessments }
  end

  column(:date_of_custom_assessments, header: -> { I18n.t('datagrid.columns.date_of_custom_assessments', assessment: I18n.t('families.show.assessment')) }, html: true) do |object|
    assessments = map_assessment_and_score(object, '', nil)
    render partial: 'families/assessments', locals: { object: assessments }
  end

  dynamic do
    column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.families.manage') }) do |object|
      render partial: 'families/actions', locals: { object: object }
    end
    column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.families.changelogs') }) do |object|
      link_to t('datagrid.columns.families.view'), family_version_path(object)
    end
  end
end
