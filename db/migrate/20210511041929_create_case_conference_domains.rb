class CreateCaseConferenceDomains < ActiveRecord::Migration
  def change
    create_table :case_conference_domains do |t|
      t.references :domain, index: true, foreign_key: true
      t.references :case_conference, index: true, foreign_key: true
      t.text :presenting_problem

      t.timestamps null: false
    end
  end
end
