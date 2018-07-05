class AddFieldsToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :org_name, :string, default: ''
    add_column :settings, :org_commune, :string, default: ''
    add_reference :settings, :province, index: true, foreign_key: true
    add_reference :settings, :district, index: true, foreign_key: true
  end
end
