class AddFormTypeFieldToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :form_type, :string
  end
end
