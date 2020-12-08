class FamilyGrid < BaseGrid
  include ClientsHelper

  attr_accessor :dynamic_columns

  scope do
    Family.includes({cases: [:client]}, :village, :commune, :district, :province).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.families.name') }) do |value, scope|
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

  filter(:caregiver_information, :string, header: -> { I18n.t('datagrid.columns.families.caregiver_information') }) do |value, scope|
    scope.caregiver_information_like(value)
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
      caregiver_information: :general,
      id: :general,
      code: :general,
      name: :general,
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

  column(:name, html: true, order: 'LOWER(name)', header: -> { I18n.t('datagrid.columns.families.name') }) do |object|
    link_to entity_name(object), family_path(object)
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

  column(:caregiver_information, order: 'LOWER(caregiver_information)', header: -> { I18n.t('datagrid.columns.families.caregiver_information') })

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

  column(:significant_family_member_count, header: -> { I18n.t('datagrid.columns.families.significant_family_member_count') })
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
