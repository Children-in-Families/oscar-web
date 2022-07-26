class AddLabelDataToFieldSettings < ActiveRecord::Migration
  FIELDS = {
    referee_address: {
      group: :referee,
      klass_name: :referee,
      current_label: 'Address',
      label: 'Current Address'
    },
    referral_info: {
      group: :client,
      klass_name: :client,
      current_label: 'Client / Referral Information',
      label: 'Client Information'
    },
    carer_information: {
      klass_name: :carer,
      group: :carer,
      current_label: 'Carer Information?',
      label: 'Caregiver Information'
    },
    case_note: {
      klass_name: :case_note,
      group: :client,
      current_label: 'Case Notes',
      label: 'Implementation Log'
    }
  }

  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FIELDS.each do |name, data|
      next if FieldSetting.find_by(name: name, klass_name: data[:klass_name])
      field_setting = FieldSetting.create!(
        name: name,
        current_label: data[:current_label],
        label: (Apartment::Tenant.current_tenant == 'ratanak' ? data[:label] : nil),
        klass_name: data[:klass_name],
        required: true,
        label_only: true,
        visible: true,
        group: data[:group] || :client
      )
    end
  end

  def down
    # FieldSetting.where(name: FIELDS.keys).delete_all
  end
end
