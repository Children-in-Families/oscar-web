class AddFieldTelephoneNumberToClient < ActiveRecord::Migration
  def change
    add_column :clients, :telephone_number, :string, default: ''
  end
end
