class CreateGovernmentFormFamilyPlans < ActiveRecord::Migration
  def change
    create_table :government_form_family_plans do |t|
      t.string :goal
      t.string :action
      t.string :result
      t.references :government_form, index: true, foreign_key: true
      t.references :family_plan, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
