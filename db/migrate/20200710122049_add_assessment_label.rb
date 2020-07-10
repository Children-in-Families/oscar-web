class AddAssessmentLabel < ActiveRecord::Migration
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FieldSetting.create!(
      name: :assessment,
      current_label: 'Assessment',
      label: (Apartment::Tenant.current_tenant == 'ratanak' ? 'Assessment Matrix' : nil),
      klass_name: :assessment,
      required: true,
      label_only: true,
      visible: true,
      group: :client
    )
  end

  def down
    FieldSetting.where(name: :assessment, klass_name: :assessment).delete_all
  end
end
