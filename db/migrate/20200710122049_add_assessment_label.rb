class AddAssessmentLabel < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current == 'shared'

    FieldSetting.create!(
      name: :assessment,
      current_label: 'Assessment',
      label: (Apartment::Tenant.current == 'ratanak' ? 'Assessment Matrix' : nil),
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
