class CaseWorkerFamilies < ActiveRecord::Migration
  def change
    create_table :case_worker_families do |t|
      t.references :user, foreign_key: true
      t.references :family, foreign_key: true
    end
  end
end
