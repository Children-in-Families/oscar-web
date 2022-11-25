class AddDonorAssociationToClients < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :donor, index: true, foreign_key: true
  end
end
