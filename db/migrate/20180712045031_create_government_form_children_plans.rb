class CreateGovernmentFormChildrenPlans < ActiveRecord::Migration
  def change
    create_table :government_form_children_plans do |t|
      t.string :goal, default: ''
      t.string :action, default: ''
      t.string :who, default: ''
      t.string :when, default: ''
      t.references :government_form, index: true, foreign_key: true
      t.references :children_plan, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
