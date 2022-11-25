class AllowOverrideRequired < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :can_override_required, :boolean, default: false
  end
end
