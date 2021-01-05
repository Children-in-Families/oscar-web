class AddMoreFieldsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :presented_id, :string
    add_column :clients, :id_number, :string
    add_column :clients, :preferred_language, :string
    add_column :clients, :whatsapp, :string
    add_column :clients, :other_phone_number, :string
    add_column :clients, :v_score, :integer
    add_column :clients, :brsc_branch, :string
    add_column :clients, :current_island, :string
    add_column :clients, :current_street, :string
    add_column :clients, :current_po_box, :string
    add_column :clients, :current_city, :string
    add_column :clients, :current_settlement, :string
    add_column :clients, :current_resident_own_or_rent, :string
    add_column :clients, :current_household_type, :string

    add_column :clients, :island2, :string
    add_column :clients, :street2, :string
    add_column :clients, :po_box2, :string
    add_column :clients, :city2, :string
    add_column :clients, :settlement2, :string
    add_column :clients, :resident_own_or_rent2, :string
    add_column :clients, :household_type2, :string
  end
end
