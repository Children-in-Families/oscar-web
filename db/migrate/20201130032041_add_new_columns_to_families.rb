class AddNewColumnsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :received_by_id, :integer
    add_column :families, :followed_up_by_id, :integer
    add_column :families, :initial_referral_date, :date
    add_column :families, :follow_up_date, :date
    add_column :families, :referral_source_category_id, :integer
    add_column :families, :referral_source_id, :integer
    add_column :families, :referee_contact, :string

    add_foreign_key :families, :users, column: :received_by_id if column_exists?(:families, :received_by_id)
    add_foreign_key :families, :users, column: :followed_up_by_id if column_exists?(:families, :followed_up_by_id)
  end
end
