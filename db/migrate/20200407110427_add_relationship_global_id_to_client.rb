class AddRelationshipGlobalIdToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :global, index: true, foreign_key: true
  end
end
