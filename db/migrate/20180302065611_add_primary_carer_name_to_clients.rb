class AddPrimaryCarerNameToClients < ActiveRecord::Migration
  def change
    add_column :clients, :primary_carer_name, :string
  end
end
