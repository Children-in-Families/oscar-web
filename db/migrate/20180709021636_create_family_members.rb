class CreateFamilyMembers < ActiveRecord::Migration
  def change
    create_table :family_members do |t|
      t.string :adult_name, default: ''
      t.date :date_of_birth
      t.string :occupation, default: ''
      t.string :relation, default: ''
      t.references :family, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
