class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :full_name
      t.string :short_name
      t.string :logo

      t.timestamps null: false
    end
  end
end
