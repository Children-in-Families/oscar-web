class CreateReferralSources < ActiveRecord::Migration
  def change
    create_table :referral_sources do |t|
      t.string :name, default: ''
      t.text :description, default: ''

      t.timestamps
    end
  end
end
