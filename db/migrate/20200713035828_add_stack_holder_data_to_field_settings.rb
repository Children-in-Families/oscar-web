class AddStackHolderDataToFieldSettings < ActiveRecord::Migration
  FIELDS = [
    :neighbor_name,
    :neighbor_phone,
    :dosavy_name,
    :dosavy_phone,
    :chief_commune_name,
    :chief_commune_phone,
    :chief_village_name,
    :chief_village_phone,
    :ccwc_name,
    :ccwc_phone,
    :legal_team_name,
    :legal_representative_name,
    :legal_team_phone,
    :other_agency_name,
    :other_representative_name,
    :other_agency_phone
  ]

  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FIELDS.each do |name|
      field_setting = FieldSetting.create!(
        name: name,
        current_label: I18n.t("clients.form.#{name}"),
        klass_name: :client,
        visible: Apartment::Tenant.current_tenant == 'ratanak',
        group: :stakeholder_contacts
      )
    end
  end

  def down
    FieldSetting.where(name: FIELDS).delete_all
  end
end
