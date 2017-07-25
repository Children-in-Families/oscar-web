class CreateCaseWorkerClient < ActiveRecord::Migration
  def change
    create_table :case_worker_clients do |t|
      t.references :user, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true

      t.timestamps
    end
  end
end
