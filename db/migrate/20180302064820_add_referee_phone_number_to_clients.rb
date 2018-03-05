class AddRefereePhoneNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :referee_phone_number, :integer
  end
end
