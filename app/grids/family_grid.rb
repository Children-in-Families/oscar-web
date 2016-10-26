class FamilyGrid
  include Datagrid

  scope do
    Family.includes(cases: { client: :user }).references(:client, :user).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.families.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.families.id') })

  filter(:address, :string, header: -> { I18n.t('datagrid.columns.families.address') }) { |value, scope| scope.address_like(value) }

  filter(:family_type, :enum, select: [%w(Kinship kinship), %w(Foster foster)], header: -> { I18n.t('datagrid.columns.families.family_type') }) do |value, scope|
    value == 'kinship' ? scope.kinship : scope.foster
  end

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

  column(:name, html: true, order: 'LOWER(name)', header: -> { I18n.t('datagrid.columns.families.name') }) do |object|
    name = object.name.blank? ? 'Unknown' : object.name
    link_to name, family_path(object)
  end

  column(:name, html: false, header: -> { I18n.t('datagrid.columns.families.name') }) do |object|
    object.name
  end

  column(:address, html: false, header: -> { I18n.t('datagrid.columns.families.address') })

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
    render partial: 'families/clients', locals: { object: object.cases.non_emergency.active }
  end

  column(:case_worker, html: true, header: -> { I18n.t('datagrid.columns.families.case_workers') }) do |object|
    render partial: 'families/case_workers', locals: { object: object.cases.non_emergency.active }
  end

  column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.families.manage') }) do |object|
    render partial: 'families/actions', locals: { object: object }
  end

  column(:significant_family_member_count, header: -> { I18n.t('datagrid.columns.families.significant_family_member_count') }, html: false)
  column(:female_children_count, header: -> { I18n.t('datagrid.columns.families.female_children_count') }, html: false)
  column(:male_children_count, header: -> { I18n.t('datagrid.columns.families.male_children_count') }, html: false)
  column(:female_adult_count, header: -> { I18n.t('datagrid.columns.families.female_adult_count') }, html: false)
  column(:male_adult_count, header: -> { I18n.t('datagrid.columns.families.male_adult_count') }, html: false)
  column(:contract_date, header: -> { I18n.t('datagrid.columns.families.contract_date') }, html: false)

  column(:province, html: false, header: -> { I18n.t('datagrid.columns.families.province') }) do |object|
    object.province.name if object.province
  end

  column(:family_type, header: -> { I18n.t('datagrid.columns.families.family_type') }, html: false) do |object|
    object.family_type.titleize
  end

  column(:cases, header: -> { I18n.t('datagrid.columns.families.clients') }, html: false) do |object|
    object.cases.non_emergency.active.map { |c| c.client.name if c.client }.join(', ')
  end
end
