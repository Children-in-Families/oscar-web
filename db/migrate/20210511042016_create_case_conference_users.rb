class CreateCaseConferenceUsers < ActiveRecord::Migration
  def change
    create_table :case_conference_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :case_conference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
