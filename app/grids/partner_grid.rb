class PartnerGrid
  include Datagrid

  scope do
    Partner.all.order(:name)
  end

  filter(:name, :string) do |value, scope|
    scope.name_like(value)
  end

  filter(:contact_person_name, :string, header: 'Contact name') do |value, scope|
    scope.contact_person_name_like(value)
  end

  filter(:contact_person_email, :string, header: 'Email') do |value, scope|
    scope.contact_person_email_like(value)
  end

  filter(:contact_person_mobile, :string, header: 'Mobile') do |value, scope|
    scope.contact_person_mobile_like(value)
  end

  filter(:organisation_type, :enum, select: :organisation_type_options)
  def organisation_type_options
    scope.organisation_type_is
  end

  filter(:affiliation, :string) do |value, scope|
    scope.affiliation_like(value)
  end

  filter(:engagement, :string) do |value, scope|
    scope.engagement_like(value)
  end

  filter(:background, :string) do |value, scope|
    scope.background_like(value)
  end

  filter(:province_id, :enum, select: :province_options)
  def province_options
    scope.province_is
  end

  filter(:address, :string) do |value, scope|
    scope.address_like(value)
  end

  filter(:start_date, :date, range: true)

  column(:name, html: true) do |object|
    name = object.name.blank? ? 'Unknown' : object.name
	  link_to name, partner_path(object)
  end

  column(:contact_person_name, header: 'Contact Name')

  column(:contact_person_email, header: 'Email') do |object|
    format(object.contact_person_email) do |object_email|
      mail_to object_email
    end
  end

  column(:contact_person_mobile, header: 'Mobile') do |object|
    object.contact_person_mobile.split('/').map{|b| b.phony_formatted(normalize: :KH, format: :international)}.join(' / ') if object.contact_person_mobile
  end

  column(:organisation_type, header: 'Type', html: true)
  column(:organisation_type, header: 'Organisation Type', html: false)

  column(:start_date, header: 'Start Date')

  column(:manage, html: true, class: 'text-center') do |object|
    if current_user.admin?
      render partial: 'partners/actions', locals: { object: object }
    end
  end

  column(:affiliation, html: false)
  column(:engagement, html: false)
  column(:background, html: false)
  column(:address, html: false)

  column(:province, html: false) do |object|
    object.province.name if object.province
  end

end