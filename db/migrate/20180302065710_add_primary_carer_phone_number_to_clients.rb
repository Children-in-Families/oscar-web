class AddPrimaryCarerPhoneNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :primary_carer_phone_number, :string
  end
end
