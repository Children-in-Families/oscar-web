class CreateOrganizationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
