class CreateCaseConferences < ActiveRecord::Migration
  def change
    create_table :case_conferences do |t|
      t.date :case_conference
      t.text :client_strength
      t.text :client_limitation
      t.text :client_engagement
      t.text :local_resource
      t.string :attachment

      t.timestamps null: false
    end
    add_index :case_conferences, :case_conference
  end
end
