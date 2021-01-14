class FamilyGrid < BaseGrid
  include ClientsHelper

  attr_accessor :dynamic_columns

  scope do
    Family.includes({cases: [:client], community_member: [:community], donor_families: [:donor], case_worker_families: [:case_worker], family_quantitative_cases: [:quantitative_case]}, :village, :commune, :district, :province).order(:name)
  end

  filter(:name, :string, header: -> { Family.human_attribute_name(:name) }) do |value, scope|
    scope.name_like(value)
  end

  filter(:name_en, :string, header: -> { Family.human_attribute_name(:name_en) }) do |value, scope|
    scope.name_en_like(value)
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

  filter(:id_poor, :enum, select: Family::ID_POOR, header: -> { Family.human_attribute_name(:id_poor) })
  filter(:received_by_id, :enum, select: :user_options, header: -> { Family.human_attribute_name(:received_by_id) })
  filter(:case_worker_ids, :enum, multiple: true, select: :user_options, header: -> { Family.human_attribute_name(:case_worker_ids) })
  filter(:initial_referral_date, :date, header: -> { Family.human_attribute_name(:initial_referral_date) })
  filter(:follow_up_date, :date, header: -> { Family.human_attribute_name(:follow_up_date) })

  filter(:referral_source_category_id, :enum, select: :referral_source_category_options, header: -> { Family.human_attribute_name(:referral_source_category_id) })
  filter(:referral_source_id, :enum, select: :referral_source_options, header: -> { Family.human_attribute_name(:referral_source_id) })

  filter(:referee_phone_number, :string, header: -> { Family.human_attribute_name(:referee_phone_number) }) do |value, scope|
    scope.referee_phone_number_like(value)
  end

  filter(:donor_ids, :enum, select: Donor.order(:name).pluck(:name, :id), header: -> { Family.human_attribute_name(:donor_ids) })
  filter(:community_id, :enum, select: Community.all.map{ |c| [c.display_name, c.id]}, header: -> { Family.human_attribute_name(:community_id) })

  def referral_source_options
    current_user.present? ? Family.joins(:case_worker_families).where(case_worker_families: { user_id: current_user.id }).referral_source_is : Family.referral_source_is
  end

  def referral_source_category_options
    if I18n.locale == :km
      ReferralSource.where(id: Family.pluck(:referral_source_category_id).compact).pluck(:name, :id)
    else
      ReferralSource.where(id: Family.pluck(:referral_source_category_id).compact).pluck(:name_en, :id)
    end
  end

  filter(:significant_family_member_count, :integer, range: true, header: -> { I18n.t('families.show.member_count') })

  filter(:female_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.female_children_count') })

  filter(:male_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.male_children_count') })

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

  def user_options
    User.deleted_user.non_strategic_overviewers.order(:first_name, :last_name).map{ |u| [u.name, u.id] }
  end

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

  filter(:dependable_income, :xboolean, header: -> { I18n.t('datagrid.columns.families.dependable_income') }) do |value, scope|
    value ? scope.where(dependable_income: true) : scope.where(dependable_income: false)
  end

  filter(:female_adult_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.female_adult_count') })

  filter(:male_adult_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.male_adult_count') })

  filter(:household_income, :float, range: true, header: -> { I18n.t('datagrid.columns.families.household_income') })

  filter(:contract_date, :date, range: true, header: -> { I18n.t('datagrid.columns.families.contract_date') })

  filter(:relevant_information, :string, header: -> { Family.human_attribute_name(:relevant_information) }) do |value, scope|
    scope.relevant_information_like(value)
  end

  def filer_section(filter_name)
    {
      street: :address,
      house: :address,
      dependable_income: :general,
      female_adult_count: :aggregrate,
      male_adult_count: :aggregrate,
      household_income: :general,
      contract_date: :general,
      relevant_information: :general,
      id: :general,
      code: :general,
      name: :general,
      name_en: :general,
      id_poor: :general,
      case_worker_ids: :general,
      followed_up_by_id: :general,
      follow_up_date: :general,
      referral_source_category_id: :general,
      referral_source_id: :general,
      referee_phone_number: :general,
      donor_ids: :general,
      community_id: :general,
      initial_referral_date: :general,
      received_by_id: :general,
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
      changelo: :aggregrate
    }[filter_name]
  end

  column(:id, header: -> { I18n.t('datagrid.columns.families.id') })

  column(:code, header: -> { I18n.t('datagrid.columns.families.code') })

  column(:name, html: true, order: 'LOWER(name)', header: -> { Family.human_attribute_name(:name) }) do |object|
    link_to entity_name(object), family_path(object)
  end

  column(:name_en, header: -> { Family.human_attribute_name(:name_en) })
  column(:id_poor, header: -> { Family.human_attribute_name(:id_poor) })
  column(:received_by_id, header: -> { Family.human_attribute_name(:received_by_id) }) do |object|
    object.received_by&.name
  end

  column(:case_worker_ids, header: -> { Family.human_attribute_name(:case_worker_ids) }) do |object|
    object.case_workers.map(&:name).join(', ')
  end

  column(:initial_referral_date, header: -> { Family.human_attribute_name(:initial_referral_date) })
  column(:follow_up_date, header: -> { Family.human_attribute_name(:follow_up_date) })
  column(:referral_source_category_id, header: -> { Family.human_attribute_name(:referral_source_category_id) }) do |object|
    object.referral_source_category&.name
  end

  column(:referral_source_id, header: -> { Family.human_attribute_name(:referral_source_id) }) do |object|
    object.referral_source&.name
  end
  column(:referee_phone_number, header: -> { Family.human_attribute_name(:referee_phone_number) })
  column(:donor_ids, header: -> { Family.human_attribute_name(:donor_ids) }) do |object|
    object.donors.map(&:name).join(', ')
  end

  column(:community_id, header: -> { Family.human_attribute_name(:community_id) }) do |object|
    object.community&.display_name
  end

  column(:family_type, header: -> { I18n.t('datagrid.columns.families.family_type') }) do |object|
    object.family_type
  end

  column(:status, header: -> { I18n.t('datagrid.columns.families.status') }) do |object|
    object.status
  end

  column(:gender, html: true, header: -> { I18n.t('activerecord.attributes.family_member.gender') }) do |object|
    content_tag :ul, class: '' do
      object.family_members.map(&:gender).each do |gender|
        concat(content_tag(:li, gender&.titleize))
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

  column(:case_history, html: true, header: -> { I18n.t('datagrid.columns.families.case_history') }) do |object|
    family_case_history(object)
  end

  column(:case_history, html: false, header: -> { I18n.t('datagrid.columns.families.case_history') })

  column(:member_count, html: true, header: -> { I18n.t('datagrid.columns.families.member_count') }, order: ('families.female_children_count, families.male_children_count, families.female_adult_count, families.male_adult_count')) do |object|
    render partial: 'families/members', locals: { object: object }
  end

  column(:relevant_information, order: 'LOWER(relevant_information)', header: -> { Family.human_attribute_name(:relevant_information) })

  column(:household_income, header: -> { I18n.t('datagrid.columns.families.household_income') })

  column(:dependable_income, header: -> { I18n.t('datagrid.columns.families.dependable_income') }) do |object|
    object.dependable_income ? 'Yes' : 'No'
  end

  column(:cases, html: true, order: false, header: -> { I18n.t('datagrid.columns.families.clients') }) do |object|
    render partial: 'families/clients', locals: { object: object }
  end

  column(:case_workers, html: true, header: -> { I18n.t('datagrid.columns.families.case_workers') }) do |object|
    render partial: 'families/case_workers', locals: { object: object.children }
  end

  column(:significant_family_member_count, header: -> { I18n.t('families.show.families.member_count') })
  column(:female_children_count, header: -> { I18n.t('datagrid.columns.families.female_children_count') })
  column(:male_children_count, header: -> { I18n.t('datagrid.columns.families.male_children_count') })
  column(:female_adult_count, header: -> { I18n.t('datagrid.columns.families.female_adult_count') })
  column(:male_adult_count, header: -> { I18n.t('datagrid.columns.families.male_adult_count') })

  date_column(:contract_date, html: true, header: -> { I18n.t('datagrid.columns.families.contract_date') })
  column(:contract_date, html: false, header: -> { I18n.t('datagrid.columns.families.contract_date') }) do |object|
    object.contract_date.present? ? object.contract_date : ''
  end

  column(:house, header: -> { I18n.t('datagrid.columns.families.house') })
  column(:street, header: -> { I18n.t('datagrid.columns.families.street') })

  column(:village, order: 'villages.name_kh', header: -> { I18n.t('datagrid.columns.families.village') }) do |object|
    object.village.try(:code_format)
  end

  column(:commune, order: 'communes.name_kh', header: -> { I18n.t('datagrid.columns.families.commune') }) do |object|
    object.commune.try(:name)
  end

  column(:district, order: 'districts.name', header: -> { I18n.t('datagrid.columns.families.district') }) do |object|
    object.district_name
  end

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.families.province') }) do |object|
    object.province_name
  end

  column(:cases, header: -> { I18n.t('datagrid.columns.families.clients') }, html: false) do |object|
    Client.where(id: object.children).map(&:name).join(', ')
  end

  column(:case_workers, header: -> { I18n.t('datagrid.columns.families.case_workers') }, html: false) do |object|
    user_ids = Client.where(id: object.children).joins(:case_worker_clients).map(&:user_ids).flatten.uniq
    User.where(id: user_ids).map{|u| u.name }.join(', ')
  end

  dynamic do
    next unless dynamic_columns.present?
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        if fields.last == 'Has This Form'
          properties = [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).count]
        else
          properties_field = 'custom_field_properties.properties'
          format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')

          basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
          basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results      = mapping_form_builder_param_value(basic_rules, 'formbuilder')

          query_string = get_query_string(results, 'formbuilder', properties_field)
          sql          = query_string.reverse.reject(&:blank?).map{|sql| "(#{sql})" }.join(" AND ")

          properties   = object.custom_field_properties.joins(:custom_field).where(sql).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).properties_by(format_field_value)
        end
        render partial: 'shared/form_builder_dynamic/properties_value', locals: { properties:  properties }
      end

    end
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
