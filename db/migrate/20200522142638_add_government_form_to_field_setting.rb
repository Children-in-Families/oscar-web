class AddGovernmentFormToFieldSetting < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    FieldSetting.create(
      name: :government_forms,
      label: 'Government Forms',
      current_label: 'Government Forms',
      klass_name: :client,
      required: false,
      visible: %w(brc ratanak).exclude?(Apartment::Tenant.current_tenant),
      group: :client
    )
  end

  def down
    FieldSetting.where(name: :government_forms).delete_all
  end
end
