class CreateDonors < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.string :name, default: ''
      t.text :description, default: ''

      t.timestamps null: false
    end
  end
end
