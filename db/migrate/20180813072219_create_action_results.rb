class CreateActionResults < ActiveRecord::Migration[5.2]
  def change
    create_table :action_results do |t|
      t.text :action, default: ''
      t.text :result, default: ''
      t.references :government_form, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
