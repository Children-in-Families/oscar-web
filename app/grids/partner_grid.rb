class PartnerGrid < BaseGrid
  include ClientsHelper

  attr_accessor :dynamic_columns
  scope do
    Partner.includes(:province, :organization_type).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('datagrid.columns.partners.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.partners.id') })

  filter(:contact_person_name, :string, header: -> { I18n.t('datagrid.columns.partners.contact_name') }) do |value, scope|
    scope.contact_person_name_like(value)
  end

  filter(:contact_person_email, :string, header: -> { I18n.t('datagrid.columns.partners.contact_email') }) do |value, scope|
    scope.contact_person_email_like(value)
  end

  filter(:contact_person_mobile, :string, header: -> { I18n.t('datagrid.columns.partners.contact_mobile') }) do |value, scope|
    scope.contact_person_mobile_like(value)
  end

  filter(:organization_type, :enum, select: :organization_type_options, header: -> { I18n.t('datagrid.columns.partners.organization_type') })

  def organization_type_options
    Partner.organization_type_are
  end

  filter(:engagement, :string, header: -> { I18n.t('datagrid.columns.partners.engagement') }) do |value, scope|
    scope.engagement_like(value)
  end

  filter(:background, :string, header: -> { I18n.t('datagrid.columns.partners.background') }) do |value, scope|
    scope.background_like(value)
  end

  filter(:province_id, :enum, select: :province_options, header: -> { I18n.t('datagrid.columns.partners.province') })
  def province_options
    Partner.province_are
  end

  filter(:address, :string, header: -> { I18n.t('datagrid.columns.partners.address') }) do |value, scope|
    scope.address_like(value)
  end

  filter(:start_date, :date, range: true, header: -> { I18n.t('datagrid.columns.partners.start_date') })

  column(:id, header: -> { I18n.t('datagrid.columns.partners.id') })

  column(:name, html: true, order: 'LOWER(partners.name)', header: -> { I18n.t('datagrid.columns.partners.name') }) do |object|
    link_to(entity_name(object), partner_path(object))
  end

  column(:name, html: false, header: -> { I18n.t('datagrid.columns.partners.name') })

  column(:contact_person_name, header: -> { I18n.t('datagrid.columns.partners.contact_name') })

  column(:contact_person_email, order: 'LOWER(partners.contact_person_email)', header: -> { I18n.t('datagrid.columns.partners.contact_email') }) do |object|
    format(object.contact_person_email) do |object_email|
      mail_to(object_email)
    end
  end

  column(:contact_person_mobile, header: -> { I18n.t('datagrid.columns.partners.contact_mobile') }) do |object|
    object.contact_person_mobile.split('/').map { |b| b.phony_formatted(normalize: :KH, format: :international) }.join(' / ') if object.contact_person_mobile
  end

  column(:organization_type, header: -> { I18n.t('datagrid.columns.partners.organization_type') }) do |object|
    object.organization_type_name
  end

  date_column(:start_date, html: true, header: -> { I18n.t('datagrid.columns.partners.start_date') })

  column(:start_date, html: false, header: -> {I18n.t('datagrid.columns.partners.start_date') }) do |object|
    object.start_date.present? ? object.start_date : ''
  end

  column(:engagement, header: -> { I18n.t('datagrid.columns.partners.engagement') })
  column(:background, header: -> { I18n.t('datagrid.columns.partners.background') })
  column(:address, header: -> { I18n.t('datagrid.columns.partners.address') })

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.partners.province') }) do |object|
    object.province.try(:name)
  end

  dynamic do
    next unless dynamic_columns.present?
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        if fields.last == 'Has This Form'
          properties = [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Partner'}).count]
        else
          properties = object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Partner'}).properties_by(format_field_value)
        end
        render partial: 'shared/form_builder_dynamic/properties_value', locals: { properties:  properties.flatten.all?{|value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ?  properties.map{|value| date_format(value.to_date) } : properties }
      end
    end
  end

  dynamic do
    column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.manage') }) do |object|
      render partial: 'partners/actions', locals: { object: object }
    end
    column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.changelogs') }) do |object|
      link_to t('datagrid.columns.partners.view'), partner_version_path(object)
    end
  end
end
