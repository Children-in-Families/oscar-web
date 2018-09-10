class CreateGovernmentFormNeed < ActiveRecord::Migration
  def change
    create_table :government_form_needs do |t|
      t.integer :rank
      t.references :need, index: true, foreign_key: true
      t.references :government_form, index: true, foreign_key: true

      t.timestamps
    end
  end
end
