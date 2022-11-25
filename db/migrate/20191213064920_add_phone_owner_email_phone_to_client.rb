class AddPhoneOwnerEmailPhoneToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :outside, :boolean, default: false
    add_column :clients, :outside_address, :string, default: ''
    add_column :clients, :address_type, :string, default: ''
    add_column :clients, :client_phone, :string, default: ''
    add_column :clients, :phone_owner, :string, default: ''
    add_column :clients, :client_email, :string, default: ''
    add_column :clients, :referee_relationship, :string, default: ''
  end
end
