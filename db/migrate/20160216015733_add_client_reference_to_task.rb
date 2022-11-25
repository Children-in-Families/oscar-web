class AddClientReferenceToTask < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :client, index: true, foreign_key: true
  end
end
