class CreateClientProblem < ActiveRecord::Migration
  def change
    create_table :client_problems do |t|
      t.integer :rank
      t.references :client, index: true, foreign_key: true
      t.references :problem, index: true, foreign_key: true
      t.timestamps
    end
  end
end
