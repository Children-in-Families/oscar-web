class CreateClientProblem < ActiveRecord::Migration[5.2]
  def change
    create_table :client_problems do |t|
      t.integer :rank
      t.references :client, index: true, foreign_key: true
      t.references :problem, index: true, foreign_key: true
      t.timestamps
    end
  end
end
