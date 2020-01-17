class CreateHotline < ActiveRecord::Migration
  def change
    create_table :hotlines do |t|
      t.references :client, index: true, foreign_key: true
      t.references :call, index: true, foreign_key: true

      t.timestamps
    end
  end
end
