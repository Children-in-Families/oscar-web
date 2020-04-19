class AddOtherPhoneWhatsappToClients < ActiveRecord::Migration
  def change
    add_column :clients, :other_phone_whatsapp, :boolean, default: false
  end
end
