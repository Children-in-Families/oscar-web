class CreateCommunityDonors < ActiveRecord::Migration
  def change
    create_table :community_donors do |t|
      t.references "donor", foreign_key: true
      t.references "community", foreign_key: true
    end
  end
end
