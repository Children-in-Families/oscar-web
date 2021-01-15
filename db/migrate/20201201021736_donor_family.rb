class DonorFamily < ActiveRecord::Migration
  def change
    create_table :donor_families do |t|
      t.references :donor, foreign_key: true
      t.references :family, foreign_key: true
    end
  end
end
