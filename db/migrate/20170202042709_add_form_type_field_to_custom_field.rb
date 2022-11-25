class AddFormTypeFieldToCustomField < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :form_type, :string
  end
end
