class CreateChangelogTypes < ActiveRecord::Migration
  def change
    create_table :changelog_types do |t|
      t.references :changelog, index: true, foreign_key: true
      t.string :change_type, default: ''
      t.string :description, default: ''
      t.timestamps
    end
  end
end
