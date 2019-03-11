class AddNgoNameToReferral < ActiveRecord::Migration
  def change
    add_column :referrals, :ngo_name, :string, default: ''
  end
end
