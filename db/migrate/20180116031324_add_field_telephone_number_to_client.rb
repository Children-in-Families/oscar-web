class AddFieldTelephoneNumberToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :telephone_number, :string, default: ''
  end
end
