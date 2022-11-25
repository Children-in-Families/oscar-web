class ChangeLegalDocNewFieldsToClients < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :ngo_partner, :string
    remove_column :clients, :mosavy, :string
    remove_column :clients, :dosavy, :string
    remove_column :clients, :msdhs, :string
    remove_column :clients, :complain, :string
    remove_column :clients, :warrant, :string
    remove_column :clients, :verdict, :string
    remove_column :clients, :short_form_of_ocdm, :string
    remove_column :clients, :short_form_of_mosavy_dosavy, :string
    remove_column :clients, :detail_form_of_mosavy_dosavy, :string
    remove_column :clients, :short_form_of_judicial_police, :string

    add_column :clients, :ngo_partner, :boolean, default: false
    add_column :clients, :mosavy, :boolean, default: false
    add_column :clients, :dosavy, :boolean, default: false
    add_column :clients, :msdhs, :boolean, default: false
    add_column :clients, :complain, :boolean, default: false
    add_column :clients, :warrant, :boolean, default: false
    add_column :clients, :verdict, :boolean, default: false
    add_column :clients, :short_form_of_ocdm, :boolean, default: false
    add_column :clients, :short_form_of_mosavy_dosavy, :boolean, default: false
    add_column :clients, :detail_form_of_mosavy_dosavy, :boolean, default: false
    add_column :clients, :short_form_of_judicial_police, :boolean, default: false
  end
end
