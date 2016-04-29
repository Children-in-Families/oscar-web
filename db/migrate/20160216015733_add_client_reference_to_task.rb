class AddClientReferenceToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :client, index: true, foreign_key: true
  end
end
