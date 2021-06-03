class AddFieldsLegalDocToClients < ActiveRecord::Migration
  def change
    add_column :clients, :ngo_partner, :string
    add_column :clients, :ngo_partner_files, :string, default: [], array: true
    add_column :clients, :mosavy, :string
    add_column :clients, :mosavy_files, :string, default: [], array: true
    add_column :clients, :dosavy, :string
    add_column :clients, :dosavy_files, :string, default: [], array: true
    add_column :clients, :msdhs, :string
    add_column :clients, :msdhs_files, :string, default: [], array: true
    add_column :clients, :complain, :string
    add_column :clients, :complain_files, :string, default: [], array: true
    add_column :clients, :warrant, :string
    add_column :clients, :warrant_files, :string, default: [], array: true
    add_column :clients, :verdict, :string
    add_column :clients, :verdict_files, :string, default: [], array: true
    add_column :clients, :referral_doc_option, :string
    add_column :clients, :short_form_of_ocdm, :string
    add_column :clients, :short_form_of_ocdm_option, :string
    add_column :clients, :short_form_of_ocdm_files, :string, default: [], array: true
    add_column :clients, :short_form_of_mosavy_dosavy, :string
    add_column :clients, :short_form_of_mosavy_dosavy_option, :string
    add_column :clients, :short_form_of_mosavy_dosavy_files, :string, default: [], array: true
    add_column :clients, :detail_form_of_mosavy_dosavy, :string
    add_column :clients, :detail_form_of_mosavy_dosavy_option, :string
    add_column :clients, :detail_form_of_mosavy_dosavy_files, :string, default: [], array: true
    add_column :clients, :short_form_of_judicial_police, :string
    add_column :clients, :short_form_of_judicial_police_option, :string
    add_column :clients, :short_form_of_judicial_police_files, :string, default: [], array: true
    add_column :clients, :detail_form_of_judicial_police, :string
    add_column :clients, :detail_form_of_judicial_police_option, :string
    add_column :clients, :detail_form_of_judicial_police_files, :string, default: [], array: true
  end
end
