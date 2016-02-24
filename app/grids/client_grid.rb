class ClientGrid
  include Datagrid

  attr_accessor :current_user

  scope do
    Client.all.includes(:user, :received_by, :followed_up_by).order(:first_name, :last_name)
  end

  filter(:first_name, :string) { |value, scope| scope.first_name_like(value) }
  filter(:last_name, :string) { |value, scope| scope.last_name_like(value) }

  filter(:gender, :enum, select: ['Male', 'Female']) do |value, scope|
    value == 'Male' ? scope.male : scope.female
  end

  filter(:date_of_birth, :date, range: true)

  filter(:status, :enum, select: :status_options)
  def status_options
    scope.status_like
  end

  filter(:birth_province_id, :enum, select: :birth_province_options)
  def birth_province_options
    current_user.present? ? scope.where(user_id: current_user.id).birth_province_is : scope.birth_province_is
  end

  filter(:initial_referral_date, :date, range: true)

  filter(:referral_phone, :string) { |value, scope| scope.referral_phone_like(value) }

  filter(:received_by_id, :enum, select: :is_received_by_options)
  def is_received_by_options
    current_user.present? ? scope.where(user_id: current_user.id).is_received_by : scope.is_received_by
  end

  filter(:referral_source_id, :enum, select: :referral_source_options)
  def referral_source_options
    current_user.present? ? scope.where(user_id: current_user.id).referral_source_is : scope.referral_source_is
  end

  filter(:followed_up_by_id, :enum, select: :is_followed_up_by_options)
  def is_followed_up_by_options
    current_user.present? ? scope.where(user_id: current_user.id).is_followed_up_by : scope.is_followed_up_by
  end

  filter(:follow_up_date, :date, range: true)

  filter(:agency_name) do |name, scope|
    if agency = Agency.name_like(name).first
      scope.joins(:agencies).where(agencies: {id: agency.id})
    else
      scope.joins(:agencies).where(agencies: {id: nil})
    end
  end

  filter(:province_id, :enum, header: 'Current province', select: :province_options)

  def province_options
    current_user.present? ? scope.where(user_id: current_user.id).province_is : scope.province_is
  end

  filter(:current_address, :string) { |value, scope| scope.current_address_like(value) }

  filter(:school_name, :string) { |value, scope| scope.school_name_like(value) }

  filter(:school_grade, :string) { |value, scope| scope.school_grade_like(value) }

  filter(:able, :xboolean, header: 'Able?')
  filter(:has_been_in_orphanage, :xboolean)
  filter(:has_been_in_government_care, :xboolean)

  filter(:relevant_referral_information, :string) { |value, scope| scope.info_like(value) }

  filter(:user_id, :enum, header: 'Case Worker', select: :case_worker_options)

  def case_worker_options
    current_user.present? ? scope.where(user_id: current_user.id).case_worker_is : scope.case_worker_is
  end

  filter(:state, :enum, select: ['Accepted', 'Rejected']) do |value, scope|
    value == 'Accepted' ? scope.accepted : scope.rejected
  end

  column(:name, order: 'clients.first_name, clients.last_name', html: true) do |object|
    name = object.name.blank? ? 'Unknown' : object.name
    link_to name, client_path(object)
  end

  column(:first_name, header: 'First Name', html: false)
  column(:last_name, header: 'Last Name', html: false)

  column(:gender) do |object|
    object.gender.titleize
  end

  column(:status)

  column(:follow_up_date, header: 'Follow Up Date') do |object|
    format(object.follow_up_date) do |object_follow_up_date|
      object_follow_up_date
    end
  end

  column(:received_by, html: true, header: 'Received By', order: false) do |object|
    render partial: 'clients/users', locals: { object: object.received_by } if object.received_by
  end

  column(:received_by, html: false, header: 'Received By') do |object|
    object.received_by.name if object.received_by
  end


  column(:followed_up_by, html: true, header: 'Followed Up By', order: false) do |object|
    render partial: 'clients/users', locals: { object: object.followed_up_by } if object.followed_up_by
  end

  column(:followed_up_by, html: false, header: 'Followed Up By') do |object|
    object.followed_up_by.name if object.followed_up_by
  end

  column(:manage, html: true, class: 'text-center') do |object|
    if current_user.admin? || object.user_id == current_user.id
      render partial: 'clients/actions', locals: { object: object }
    end
  end

  column(:agency, header: 'Agencies Involved', html: false) do |object|
    object.agencies.map{|agency| agency.name }.join(', ')
  end

  column(:date_of_birth, header: 'Date Of Birth', html: false)

  column(:current_address, header: 'Current Address', html: false)

  column(:school_name, header: 'School Name', html: false)

  column(:school_grade, header: 'School Grade', html: false)

  column(:has_been_in_orphanage, header: 'Has Been In Orphanage?', html: false) do |object|
    object.has_been_in_orphanage ? 'Yes' : 'No'
  end

  column(:has_been_in_government_care, header: 'Has Been In Government Care?', html: false) do |object|
    object.has_been_in_government_care ? 'Yes' : 'No'
  end

  column(:initial_referral_date, header: 'Initial Referral Date', html: false)

  column(:relevant_referral_information, header: 'Relevant Referral Information', html: false)

  column(:referral_phone, header: 'Referral Phone', html: false) do |object|
    object.referral_phone.phony_formatted(normalize: :KH, format: :international) if object.referral_phone
  end

  column(:referral_source, header: 'Referral Source', html: false) do |object|
    object.referral_source.name if object.referral_source
  end

  column(:able, header: 'Able?', html: false) do |object|
    object.able ? 'Yes' : 'No'
  end

  column(:birth_province, header: 'Birth Province', html: false) do |object|
    object.birth_province.name if object.birth_province
  end

  column(:province, header: 'Current Province', html: false) do |object|
    object.province.name if object.province
  end

  column(:state, html: false)
  column(:rejected_note, html: false, header: 'Rejected Note')
  column(:status, html: false)

  column(:user, header: 'Case Worker / Staff', html: false) do |object|
    object.user.name if object.user
  end

end