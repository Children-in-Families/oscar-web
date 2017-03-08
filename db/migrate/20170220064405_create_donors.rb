class CreateDonors < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end