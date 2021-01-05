class AddHotlineFieldsToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :nickname, :string, default: ''
    # Relationship to Caller
    add_column :clients, :relation_to_referee, :string, default: ''

    add_column :clients, :concern_is_outside, :boolean, default: false
    add_column :clients, :concern_outside_address, :boolean, default: false

    add_column :clients, :concern_province_id, :integer
    add_column :clients, :concern_district_id, :integer
    add_column :clients, :concern_commune_id, :integer
    add_column :clients, :concern_village_id, :integer
    add_column :clients, :concern_street, :string, default: ''
    add_column :clients, :concern_house, :string, default: ''
    add_column :clients, :concern_address, :string, default: ''
    add_column :clients, :concern_address_type, :string, default: ''
    add_column :clients, :concern_phone, :string, default: ''
    add_column :clients, :concern_phone_owner, :string, default: ''
    add_column :clients, :concern_email, :string, default: ''
    add_column :clients, :concern_email_owner, :string, default: ''
    add_column :clients, :concern_location, :string, default: ''
  end
end
