class AddedFieldsToEnterNgos < ActiveRecord::Migration
  def change
    add_column :enter_ngos, :follow_up_date, :datetime
    add_column :enter_ngos, :initial_referral_date, :datetime
    add_column :enter_ngos, :received_by_id, :integer
    add_column :enter_ngos, :followed_up_by_id, :integer

    add_index :enter_ngos, :follow_up_date
    add_index :enter_ngos, :initial_referral_date
    add_index :enter_ngos, :received_by_id
    add_index :enter_ngos, :followed_up_by_id
  end
end
