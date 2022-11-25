class CreateFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :families do |t|

      t.string  :code
      t.string  :name, default: ''
      t.string  :address, default: ''
      t.text    :caregiver_information, default: ''
      t.integer :significant_family_member_count, default: 1
      t.float   :household_income, default: 0
      t.boolean :dependable_income, default: false
      t.integer :female_children_count, default: 0
      t.integer :male_children_count, default: 0
      t.integer :female_adult_count, default: 0
      t.integer :male_adult_count, default: 0
      t.string  :family_type, default: 'kinship'
      t.date    :contract_date

      t.references :province

      t.timestamps
    end
  end
end
