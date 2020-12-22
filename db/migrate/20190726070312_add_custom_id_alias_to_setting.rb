class AddCustomIdAliasToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :custom_id1_latin, :string, default: '' if !column_exists? :settings, :custom_id1_latin
    add_column :settings, :custom_id1_local, :string, default: '' if !column_exists? :settings, :custom_id1_local
    add_column :settings, :custom_id2_latin, :string, default: '' if !column_exists? :settings, :custom_id2_latin
    add_column :settings, :custom_id2_local, :string, default: '' if !column_exists? :settings, :custom_id2_local
  end
end
