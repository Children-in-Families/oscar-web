class ChangeFormTypeToForomTitleInCustomFields < ActiveRecord::Migration
  def change
    rename_column :custom_fields, :form_type, :form_title
    change_column :custom_fields, :form_title, :string, default: ''
  end
end
