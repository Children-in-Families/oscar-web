class CreateClientTypeGovernmentForm < ActiveRecord::Migration
  def change
    create_table :client_type_government_forms do |t|
      t.references :client_type, index: true, foreign_key: true
      t.references :government_form, index: true, foreign_key: true

      t.timestamps
    end
  end
end
