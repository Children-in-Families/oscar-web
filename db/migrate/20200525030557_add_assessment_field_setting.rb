class AddAssessmentFieldSetting < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    field_setting = FieldSetting.create!(
      name: :reason,
      current_label: 'Observation',
      klass_name: :assessment,
      required: true,
      visible: true,
      group: :assessment
    )

    field_setting.update!(label: 'Review current need') if Apartment::Tenant.current_tenant == 'ratanak'
  end

  def down
    FieldSetting.where(name: :reason).delete_all
  end
end
