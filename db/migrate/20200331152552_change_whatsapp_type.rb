class ChangeWhatsappType < ActiveRecord::Migration
  def change
    remove_column :clients, :whatsapp, :string
    add_column :clients, :whatsapp, :boolean, default: false
  end
end
