class CreateDomainGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :domain_groups do |t|
      t.string :name, default: ''
      t.text :description, default: ''

      t.timestamps
    end
  end
end
