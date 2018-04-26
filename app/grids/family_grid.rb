class FamilyGrid
  include Datagrid
  include ClientsHelper

  attr_accessor :dynamic_columns

  scope do
    Family.includes({cases: [:client]}, :province).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.families.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.families.id') })

  filter(:code, :string, header: -> { I18n.t('datagrid.columns.families.code') }) do |value, scope|
    scope.family_id_like(value)
  end

  filter(:family_type, :enum, select: [['Birth Family', 'birth_family'], %w(Emergency emergency), %w(Foster foster), %w(Inactive inactive), %w(Kinship kinship)], header: -> { I18n.t('datagrid.columns.families.family_type') }) do |value, scope|
    scope.by_family_type(value)
  end

  filter(:case_history, :string, header: -> { I18n.t('datagrid.columns.families.case_history') }) do |value, scope|
    scope.case_history_like(value)
  end

  filter(:address, :string, header: -> { I18n.t('datagrid.columns.families.address') }) { |value, scope| scope.address_like(value) }

  filter(:significant_family_member_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.significant_family_member_count') })

  filter(:female_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.female_children_count') })

  filter(:male_children_count, :integer, range: true, header: -> { I18n.t('datagrid.columns.families.male_children_count') })

  filter(:province_id, :enum, select: :province_options, header: -> { I18n.t('datagrid.columns.families.province') })

  def province_options
    Family.province_are
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

  column(:id, header: -> { I18n.t('datagrid.columns.families.id') })

  column(:code, header: -> { I18n.t('datagrid.columns.families.code') })

  column(:name, html: true, order: 'LOWER(name)', header: -> { I18n.t('datagrid.columns.families.name') }) do |object|
    link_to entity_name(object), family_path(object)
  end

  column(:name, html: false, header: -> { I18n.t('datagrid.columns.families.name') })

  column(:family_type, header: -> { I18n.t('datagrid.columns.families.family_type') }) do |object|
    object.family_type.titleize
  end

  column(:case_history, html: true, header: -> { I18n.t('datagrid.columns.families.case_history') }) do |object|
    family_case_history(object)
  end

  column(:case_history, html: false, header: -> { I18n.t('datagrid.columns.families.case_history') })

  column(:address, header: -> { I18n.t('datagrid.columns.families.address') })

  column(:member_count, html: true, header: -> { I18n.t('datagrid.columns.families.member_count') }, order: ('families.female_children_count, families.male_children_count, families.female_adult_count, families.male_adult_count')) do |object|
    render partial: 'families/members', locals: { object: object }
  end

  column(:caregiver_information, order: 'LOWER(caregiver_information)', header: -> { I18n.t('datagrid.columns.families.caregiver_information') })

  column(:household_income, header: -> { I18n.t('datagrid.columns.families.household_income') }) do |object|
    format(object.household_income) do |income|
      number_to_currency income
    end
  end

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
  column(:contract_date, header: -> { I18n.t('datagrid.columns.families.contract_date') })

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.families.province') }) do |object|
    object.province.try(:name)
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
      fields = column_builder[:id].gsub('&qoute;', '"').split('_')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        properties = object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).properties_by(format_field_value)
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
