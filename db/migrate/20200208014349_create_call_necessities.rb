class CreateCallNecessities < ActiveRecord::Migration
  def change
    create_table :call_necessities do |t|
      t.references :call, index: true, foreign_key: true
      t.references :necessity, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
