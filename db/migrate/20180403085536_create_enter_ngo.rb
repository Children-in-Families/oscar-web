class CreateEnterNgo < ActiveRecord::Migration
  def change
    create_table :enter_ngos do |t|
      t.date :accepted_date
      t.references :client, index: true, foreign_key: true
      t.timestamps
    end
  end
end
