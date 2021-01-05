class CreateSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsors do |t|
      t.references :client, index: true, foreign_key: true
      t.references :donor, index: true, foreign_key: true

      t.timestamps
    end
  end
end
