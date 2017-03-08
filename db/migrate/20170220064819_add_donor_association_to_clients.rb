class AddDonorAssociationToClients < ActiveRecord::Migration
  def change
    add_reference :clients, :donor, index: true, foreign_key: true
  end
end
