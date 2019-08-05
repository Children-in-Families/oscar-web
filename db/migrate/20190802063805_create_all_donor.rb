class CreateAllDonor < ActiveRecord::Migration
  def change
    create_table :all_donors do |t|
      t.string :name, default: ''

      t.timestamps
    end
  end
end
