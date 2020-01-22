class CreateProtectionConcerns < ActiveRecord::Migration
  def change
    create_table :protection_concerns do |t|
      t.string :content, default: ''

      t.timestamps null: false
    end
  end
end
