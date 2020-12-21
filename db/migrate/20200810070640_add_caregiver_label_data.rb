class AddCaregiverLabelData < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current == 'shared'

    FieldSetting.create!(
      name: :email,
      current_label: 'Carer Email Address',
      label: (Apartment::Tenant.current == 'ratanak' ? 'Caregiver Email Address' : nil),
      klass_name: :carer,
      visible: true,
      group: :carer
    )
  end

  def down
    FieldSetting.where(name: :email, klass_name: :carer).delete_all
  end
end
