class AddNgoNameToReferral < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :ngo_name, :string, default: ''
  end
end
