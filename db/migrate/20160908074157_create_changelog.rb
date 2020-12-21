class CreateChangelog < ActiveRecord::Migration[5.2]
  def change
    create_table :changelogs do |t|
      t.string :version, default: ''
      t.string :description, default: ''
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
    add_column :users, :changelogs_count, :integer, default: 0
  end
end
