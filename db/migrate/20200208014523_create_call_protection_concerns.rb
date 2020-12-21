class CreateCallProtectionConcerns < ActiveRecord::Migration[5.2]
  def change
    create_table :call_protection_concerns do |t|
      t.references :call, index: true, foreign_key: true
      t.references :protection_concern, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
