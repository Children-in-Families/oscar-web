class ClientGrid
  include Datagrid

  attr_accessor :current_user

  scope do
    Client.includes({ cases: [:family, :partner] }, :referral_source, :user, :received_by, :followed_up_by, :province, :agencies).order(:status, :first_name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.clients.name') }) { |value, scope| scope.first_name_like(value) }

  filter(:gender, :enum, select: %w(Male Female), header: -> { I18n.t('datagrid.columns.clients.gender') }) do |value, scope|
    value == 'Male' ? scope.male : scope.female
  end

  filter(:slug, :string, header: -> {I18n.t('datagrid.columns.clients.id')})  { |value, scope| scope.slug_like(value) }

  filter(:code, :integer, header: -> { I18n.t('datagrid.columns.clients.code') }) { |value, scope| scope.start_with_code(value) }

  filter(:status, :enum, select: :status_options, header: -> { I18n.t('datagrid.columns.clients.status') })

  def status_options
    scope.status_like
  end

  filter(:case_type, :enum, select: :case_types, header: -> { I18n.t('datagrid.columns.cases.case_type') }) do |name, scope|
    scope.joins(:cases).where('LOWER(cases.case_type) = ?', name.downcase) if name.present?
  end

  def case_types
    Case.case_types
  end
  filter(:date_of_birth, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.date_of_birth') })

  filter(:age, :integer, range: true, header: -> { I18n.t('datagrid.columns.clients.age') }) do |value, scope|
    scope.age_between(value[0], value[1]) if value[0].present? && value[1].present?
  end

  filter(:birth_province_id, :enum, select: :province_with_birth_place, header: -> { I18n.t('datagrid.columns.clients.birth_province') })
  def province_with_birth_place
    Province.birth_places.map { |p| [p.name, p.id] }
  end

  filter(:province_id, :enum, select: :province_with_clients, header: -> { I18n.t('datagrid.columns.clients.current_province') })

  def province_with_clients
    Province.has_clients.map { |p| [p.name, p.id] }
  end

  filter(:initial_referral_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  filter(:referral_phone, :string, header: -> { I18n.t('datagrid.columns.clients.referral_phone') }) { |value, scope| scope.referral_phone_like(value) }

  filter(:received_by_id, :enum, select: :is_received_by_options, header: -> { I18n.t('datagrid.columns.clients.received_by') })

  def is_received_by_options
    current_user.present? ? scope.where(user_id: current_user.id).is_received_by : scope.is_received_by
  end

  filter(:referral_source_id, :enum, select: :referral_source_options, header: -> { I18n.t('datagrid.columns.clients.referral_source') })

  def referral_source_options
    current_user.present? ? scope.where(user_id: current_user.id).referral_source_is : scope.referral_source_is
  end

  filter(:followed_up_by_id, :enum, select: :is_followed_up_by_options, header: -> { I18n.t('datagrid.columns.clients.follow_up_by') })

  def is_followed_up_by_options
    current_user.present? ? scope.where(user_id: current_user.id).is_followed_up_by : scope.is_followed_up_by
  end

  filter(:follow_up_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') })

  def agencies_options
    Agency.joins(:clients).pluck(:name).uniq
  end

  filter(:agencies_name, :enum, multiple: true, select: :agencies_options, header: -> { I18n.t('datagrid.columns.clients.agency_names') }) do |name, scope|
    if agencies ||= Agency.name_like(name)
      scope.joins(:agencies).where(agencies: { id: agencies.ids })
    else
      scope.joins(:agencies).where(agencies: { id: nil })
    end
  end

  filter(:current_address, :string, header: -> { I18n.t('datagrid.columns.clients.current_address') }) { |value, scope| scope.current_address_like(value) }

  filter(:school_name, :string, header: -> { I18n.t('datagrid.columns.clients.school_name') }) { |value, scope| scope.school_name_like(value) }

  filter(:has_been_in_government_care, :xboolean, header: -> { I18n.t('datagrid.columns.clients.has_been_in_government_care') })

  filter(:grade, :integer, range: true, header: -> { I18n.t('datagrid.columns.clients.school_grade') })

  filter(:able, :xboolean, header: -> { I18n.t('datagrid.columns.clients.able') })

  filter(:has_been_in_orphanage, :xboolean, header: -> { I18n.t('datagrid.columns.clients.has_been_in_orphanage') })

  filter(:relevant_referral_information, :string, header: -> { I18n.t('datagrid.columns.clients.relevant_referral_information') }) { |value, scope| scope.info_like(value) }

  filter(:user_id, :enum, select: :user_select_options, header: -> { I18n.t('datagrid.columns.clients.case_worker') })

  def user_select_options
    User.has_clients.map { |user| [user.name, user.id] }
  end

  filter(:state, :enum, select: %w(Accepted Rejected), header: -> { I18n.t('datagrid.columns.clients.state') }) do |value, scope|
    value == 'Accepted' ? scope.accepted : scope.rejected
  end

  filter(:family_id, :integer, header: -> { I18n.t('datagrid.columns.families.family_id') }) do |value, object|
    object.find_by_family_id(value) if value.present?
  end

  # def quantitative_cases_options
  #   QuantitativeCase.joins(:clients).pluck(:value).uniq
  # end

  # filter(:quantitative_cases_value, :enum, multiple: true, select: :quantitative_cases_options, header: -> { I18n.t('datagrid.columns.clients.quantitative_case_values') }) do |value, scope|
  #   if quantitative_cases ||= QuantitativeCase.value_like(value)
  #     scope.joins(:quantitative_cases).where(quantitative_cases: { id: quantitative_cases.ids }).uniq
  #   else
  #     scope.joins(:quantitative_cases).where(quantitative_cases: { id: nil })
  #   end
  # end

  def quantitative_type_options
    QuantitativeType.all.map{ |t| [t.name, t.id] }
  end

  filter(:quantitative_types, :enum, select: :quantitative_type_options, header: -> { I18n.t('datagrid.columns.clients.quantitative_types') }) do |value, scope|
    scope.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: value.to_i }).uniq
  end

  column(:slug, order:'clients.id', header: -> { I18n.t('datagrid.columns.clients.id') })

  column(:code, header: -> { I18n.t('datagrid.columns.clients.code') }) do |object|
    object.code.present? ? object.code : ''
  end

  column(:name, order: 'LOWER(clients.first_name)', header: -> { I18n.t('datagrid.columns.clients.name') }, html: true) do |object|
    name = object.name.blank? ? 'Unknown' : object.name
    link_to name, client_path(object)
  end

  column(:name, header: -> { I18n.t('datagrid.columns.clients.name') }, html: false) do |object|
    object.name
  end

  column(:gender, header: -> { I18n.t('datagrid.columns.clients.gender') }) do |object|
    object.gender.titleize if object.gender
  end

  column(:status, header: -> { I18n.t('datagrid.columns.clients.status') }) do |object|
    format(object.status) do |value|
      status_style(value)
    end
  end

  column(:cases, header: -> { I18n.t('datagrid.columns.cases.case_type') }, order: 'cases.case_type') do |object|
    object.cases.most_recents.first.case_type if object.cases.any?
  end

  column(:history_of_disability_and_or_illness, header: -> { I18n.t('datagrid.columns.clients.history_of_disability_and_or_illness') }) do |object|
    object.quantitative_cases.where(quantitative_type_id: QuantitativeType.name_like('History of disability and/or illness').ids).pluck(:value).join(', ')
  end

  column(:history_of_harm, header: -> { I18n.t('datagrid.columns.clients.history_of_harm') }) do |object|
    object.quantitative_cases.where(quantitative_type_id: QuantitativeType.name_like('History of Harm').ids).pluck(:value).join(', ')
  end

  column(:history_of_high_risk_behaviours, header: -> { I18n.t('datagrid.columns.clients.history_of_high_risk_behaviours') }) do |object|
    object.quantitative_cases.where(quantitative_type_id: QuantitativeType.name_like('History of high-risk behaviours').ids).pluck(:value).join(', ')
  end

  column(:reason_for_family_separation, header: -> { I18n.t('datagrid.columns.clients.reason_for_family_separation') }) do |object|
    object.quantitative_cases.where(quantitative_type_id: QuantitativeType.name_like('Reason for Family Separation').ids).pluck(:value).join(', ')
  end  

  column(:follow_up_date, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') }) do |object|
    format(object.follow_up_date) do |object_follow_up_date|
      object_follow_up_date
    end
  end

  column(:received_by, html: true, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
    render partial: 'clients/users', locals: { object: object.received_by } if object.received_by
  end

  column(:received_by, html: false, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
    object.received_by.name if object.received_by
  end

  column(:followed_up_by, html: true, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
    render partial: 'clients/users', locals: { object: object.followed_up_by } if object.followed_up_by
  end

  column(:followed_up_by, html: false, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
    object.followed_up_by.name if object.followed_up_by
  end

  column(:agency, order: 'agencies.name', header: -> { I18n.t('datagrid.columns.clients.agencies_involved') }) do |object|
    object.agencies.pluck(:name).join(', ')
  end

  column(:date_of_birth, header: -> { I18n.t('datagrid.columns.clients.date_of_birth') })

  column(:age, header: -> { I18n.t('datagrid.columns.clients.age') }, order: 'clients.date_of_birth desc') do |object|
    "#{object.age_as_years} #{'year'.pluralize(object.age_as_years)} #{object.age_extra_months} #{'month'.pluralize(object.age_extra_months)}" if object.date_of_birth.present?
  end

  column(:current_address, order: 'LOWER(current_address)', header: -> { I18n.t('datagrid.columns.clients.current_address') })

  column(:school_name, header: -> { I18n.t('datagrid.columns.clients.school_name') })

  column(:grade, header: -> { I18n.t('datagrid.columns.clients.school_grade') })

  column(:has_been_in_orphanage, header: -> { I18n.t('datagrid.columns.clients.has_been_in_orphanage') }) do |object|
    object.has_been_in_orphanage ? 'Yes' : 'No'
  end

  column(:has_been_in_government_care, header: -> { I18n.t('datagrid.columns.clients.has_been_in_government_care') }) do |object|
    object.has_been_in_government_care ? 'Yes' : 'No'
  end

  column(:initial_referral_date, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  column(:relevant_referral_information, header: -> { I18n.t('datagrid.columns.clients.relevant_referral_information') })

  column(:referral_phone, header: -> { I18n.t('datagrid.columns.clients.referral_phone') }) do |object|
    object.referral_phone.phony_formatted(normalize: :KH, format: :international) if object.referral_phone
  end

  column(:referral_source, order: 'referral_sources.name', header: -> { I18n.t('datagrid.columns.clients.referral_source') }) do |object|
    object.referral_source.name if object.referral_source
  end

  column(:able, header: -> { I18n.t('datagrid.columns.clients.able') }) do |object|
    object.able ? 'Yes' : 'No'
  end

  column(:birth_province, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
    object.birth_province.name if object.birth_province
  end

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
    object.province.name if object.province
  end

  column(:state, header: -> { I18n.t('datagrid.columns.clients.state') }) do |object|
    object.state.titleize
  end

  column(:rejected_note, header: -> { I18n.t('datagrid.columns.clients.rejected_note') })

  column(:user, order: 'users.first_name', header: -> { I18n.t('datagrid.columns.clients.case_worker_or_staff') }) do |object|
    object.user.name if object.user
  end

  column(:case_start_date, order: 'cases.start_date', header: -> { I18n.t('datagrid.columns.clients.placements.start_date') }) do |object|
    object.cases.current.start_date if object.cases.current
  end

  column(:carer_names, order: 'cases.carer_names', header: -> { I18n.t('datagrid.columns.clients.placements.carer_names') }) do |object|
    object.cases.current.carer_names if object.cases.current
  end

  column(:carer_address, order: 'cases.carer_address', header: -> { I18n.t('datagrid.columns.clients.placements.carer_address') }) do |object|
    object.cases.current.carer_address if object.cases.current
  end

  column(:carer_phone_number, order: 'cases.carer_phone_number', header: -> { I18n.t('datagrid.columns.clients.placements.carer_phone_number') }) do |object|
    object.cases.current.carer_phone_number if object.cases.current
  end

  column(:support_amount, order: 'cases.support_amount', header: -> { I18n.t('datagrid.columns.clients.placements.support_amount') }) do |object|
    if object.cases.current
      format(object.cases.current.support_amount) do |amount|
        number_to_currency(amount)
      end
    end
  end

  column(:support_note, order: 'cases.support_note', header: -> { I18n.t('datagrid.columns.clients.placements.support_note') }) do |object|
    object.cases.current.support_note if object.cases.current
  end

  column(:family_preservation, order: 'cases.family_preservation', header: -> { I18n.t('datagrid.columns.families.family_preservation') }) do |object|
    object.cases.current.family_preservation ? 'Yes' : 'No' if object.cases.current
  end

  column(:family_id, order: 'families.id', header: -> { I18n.t('datagrid.columns.families.family_id') }) do |object|
    if object.cases.current && object.cases.current.family
      object.cases.current.family.id
    end
  end

  column(:family, order: 'families.name', header: -> { I18n.t('datagrid.columns.clients.placements.family') }) do |object|
    if object.cases.current && object.cases.current.family
      object.cases.current.family.name
    end
  end

  column(:partner, order: 'partners.name', header: -> { I18n.t('datagrid.columns.partners.partner') }) do |object|
    if object.cases.current && object.cases.current.partner
      object.cases.current.partner.name
    end
  end

  column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.manage') }) do |object|
    render partial: 'clients/actions', locals: { object: object }
  end
end
