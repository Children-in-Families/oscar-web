class AddStackHolderToClients < ActiveRecord::Migration
  def change
    add_column :clients, :neighbor_name, :string
    add_column :clients, :neighbor_phone, :string

    add_column :clients, :dosavy_name, :string
    add_column :clients, :dosavy_phone, :string
    add_column :clients, :chief_commune_name, :string
    add_column :clients, :chief_commune_phone, :string
    add_column :clients, :chief_village_name, :string
    add_column :clients, :chief_village_phone, :string
    add_column :clients, :ccwc_name, :string
    add_column :clients, :ccwc_phone, :string

    add_column :clients, :legal_team_name, :string
    add_column :clients, :legal_representative_name, :string
    add_column :clients, :legal_team_phone, :string

    add_column :clients, :other_agency_name, :string
    add_column :clients, :other_representative_name, :string
    add_column :clients, :other_agency_phone, :string
  end
end
