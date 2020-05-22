class AddGovernmentFormToFieldSetting < ActiveRecord::Migration
  def up
    Organization.find_each do |organisation|
      Organization.switch_to(organisation.short_name)

      next if Organization.shared?

      FieldSetting.create(
        name: :government_forms,
        label: 'Government Forms',
        current_label: 'Government Forms',
        klass_name: :client,
        required: false,
        visible: %w(brc ratanak).exclude?(organisation.short_name),
        group: :client
      )
    end
  end

  def down
    Organization.find_each do |organisation|
      Organization.switch_to(organisation.short_name)

      next if Organization.shared?

      FieldSetting.where(name: :government_forms).delete_all
    end
  end
end
