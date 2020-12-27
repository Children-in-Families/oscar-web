class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.text :description, default: ''
      t.references :assessment_domain, index: true, foreign_key: true
      t.references :domain, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true
      t.references :assessment, index: true, foreign_key: true
      t.references :care_plan, index: true, foreign_key: true

      t.timestamps
    end
  end
end
