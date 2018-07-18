class CreateGovernmentFormServiceTypes < ActiveRecord::Migration
  def change
    create_table :government_form_service_types do |t|
      t.references :government_form, index: true, foreign_key: true
      t.references :service_type, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
