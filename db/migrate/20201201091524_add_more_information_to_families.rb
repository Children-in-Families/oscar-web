class AddMoreInformationToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :name_en, :string
    add_column :families, :phone_number, :string
    add_column :families, :id_poor, :string
    add_column :families, :relevant_information, :text
    add_column :families, :referee_phone_number, :string
  end
end