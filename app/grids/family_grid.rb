class FamilyGrid
  include Datagrid

  scope do
    Family.all.order(:name)
  end

  filter(:name, :string) do |value, scope|
    scope.name_like(value)
  end

  filter(:significant_family_member_count, :integer, range: true)

  filter(:address, :string) { |value, scope| scope.address_like(value) }

  filter(:female_children_count, :integer, range: true)

  filter(:family_type, :enum, select: [['Kinship','kinship'],['Foster','foster']]) do |value, scope|
    value == 'kinship' ? scope.kinship : scope.foster
  end

  filter(:male_children_count, :integer, range: true)

  filter(:province_id, :enum, select: :province_options)
  def province_options
    scope.province_is
  end

  filter(:female_adult_count, :integer, range: true)

  filter(:dependable_income, :xboolean) do |value, scope|
    value ? scope.where(dependable_income: true) : scope.where(dependable_income: false)
  end

  filter(:male_adult_count, :integer, range: true)

  filter(:caregiver_information, :string) do |value, scope|
    scope.caregiver_information_like(value)
  end

  filter(:household_income, :float, range: true)

  filter(:contract_date, :date, range: true)

  column(:name, header: 'Name', html: true) do |object|
    name = object.name.blank? ? 'Unknown' : object.name
    link_to name, family_path(object)
  end

  column(:address, html: false)

  column(:member_count, html: true, header: 'Member Count') do |object|
    render partial: 'families/members', locals: { object: object }
  end

  column(:caregiver_information, header: 'Caregiver Information')

  column(:household_income, header: 'Household Income ($)') do |object|
    format(object.household_income) do |income|
      number_to_currency income
    end
  end

  column(:dependable_income, header: 'Dependable Income?') do |object|
    object.dependable_income ? 'Yes' : 'No'
  end

  column(:cases, html: true, header: 'Clients') do |object|
    render partial: 'families/clients', locals: { object: object.cases.non_emergency.active }
  end


  column(:manage, html: true, class: 'text-center') do |object|
    if current_user.admin?
      render partial: 'families/actions', locals: { object: object }
    end
  end

  column(:significant_family_member_count, header: 'Significant Family Member Count', html: false)
  column(:female_children_count, header: 'Female Children Count', html: false)
  column(:male_children_count, header: 'Male Children Count', html: false)
  column(:female_adult_count, header: 'Female Adult Count', html: false)
  column(:male_adult_count, header: 'Male Adult Count', html: false)
  column(:contract_date, header: 'Contract Date', html: false)

  column(:province, html: false) do |object|
    object.province.name if object.province
  end

  column(:family_type, header: 'Family Type', html: false) do |object|
    object.family_type.titleize
  end

  column(:cases, header: 'Clients', html: false) do |object|
    object.cases.map{|c| c.client.name if c.client }.join(', ')
  end

end