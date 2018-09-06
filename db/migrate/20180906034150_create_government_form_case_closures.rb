class CreateGovernmentFormCaseClosures < ActiveRecord::Migration
  def change
    create_table :government_form_case_closures do |t|
      t.references :government_form, index: true, foreign_key: true
      t.references :case_closure, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
