class CreateClientRightGovernmentForms < ActiveRecord::Migration
  def change
    create_table :client_right_government_forms do |t|
      t.references :government_form, index: true, foreign_key: true
      t.references :client_right, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
