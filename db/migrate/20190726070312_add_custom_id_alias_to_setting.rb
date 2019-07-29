class AddCustomIdAliasToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :custom_id1_latin, :string, default: ''
    add_column :settings, :custom_id1_local, :string, default: ''
    add_column :settings, :custom_id2_latin, :string, default: ''
    add_column :settings, :custom_id2_local, :string, default: ''
  end
end
