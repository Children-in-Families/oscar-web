class AddFieldRefereeIdToReferral < ActiveRecord::Migration
  def change
    add_column :referrals, :referee_id, :integer
  end
end
