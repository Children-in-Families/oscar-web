class AddCaregiverLabelData < ActiveRecord::Migration
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FieldSetting.create!(
      name: :email,
      current_label: 'Carer Email Address',
      label: (Apartment::Tenant.current_tenant == 'ratanak' ? 'Caregiver Email Address' : nil),
      klass_name: :carer,
      visible: true,
      group: :carer
    )
  end

  def down
    FieldSetting.where(name: :email, klass_name: :carer).delete_all
  end
end
