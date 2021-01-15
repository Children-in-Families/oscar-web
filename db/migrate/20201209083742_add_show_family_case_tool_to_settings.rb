class AddShowFamilyCaseToolToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :hide_family_case_management_tool, :boolean, default: true, null: false
  end
end
