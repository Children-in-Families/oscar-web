class AddShowFamilyCaseToolToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :hide_family_case_management_tool, :boolean, default: true, null: false
  end
end
