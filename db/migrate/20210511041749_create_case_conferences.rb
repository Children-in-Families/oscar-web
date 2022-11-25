class CreateCaseConferences < ActiveRecord::Migration[5.2]
  def change
    create_table :case_conferences do |t|
      t.datetime :meeting_date
      t.text :client_strength
      t.text :client_limitation
      t.text :client_engagement
      t.text :local_resource
      t.string :attachments, default: [],    array: true
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :case_conferences, :meeting_date
  end
end
