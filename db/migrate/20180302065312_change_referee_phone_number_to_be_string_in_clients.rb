class ChangeRefereePhoneNumberToBeStringInClients < ActiveRecord::Migration
  def change
    change_column :clients, :referee_phone_number, :string
  end
end
