class AddDocumentsToFieldSettings < ActiveRecord::Migration[5.2]
  FIELDS = {
    :national_id => 'National ID',
    :birth_cert => 'Birth Certificate',
    :family_book => 'Family Book',
    :passport => 'Passport',
    :travel_doc => 'Temporary Travel Document',
    :referral_doc => 'Referral Documents',
    :local_consent => 'Legal consent',
    :police_interview => 'Police interview',
    :other_legal_doc => 'Others'
  }

  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FIELDS.each do |name, label|
      field_setting = FieldSetting.create!(
        name: name,
        current_label: label,
        label: label,
        klass_name: :client,
        required: false,
        visible: (Apartment::Tenant.current_tenant == 'ratanak'),
        group: :client
      )
    end
  end

  def down
    FieldSetting.where(name: FIELDS.keys).delete_all
  end
end
