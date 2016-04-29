class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name, default: ''
      t.string :identity, default: ''
      t.text :description, default: ''
      t.references :domain_group, index: true, foreign_key: true

      t.timestamps
    end
  end
end
