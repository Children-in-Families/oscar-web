class CreateFollowUpRecords < ActiveRecord::Migration
  def change
    create_table :follow_up_records do |t|
      t.date :date
      t.string :provided_service, default: ''
      t.string :child_family_status, default: ''
      t.references :government_form, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
