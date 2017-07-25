class CreateCaseWorkerTask < ActiveRecord::Migration
  def change
    create_table :case_worker_tasks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :task, index: true, foreign_key: true

      t.timestamps
    end
  end
end
