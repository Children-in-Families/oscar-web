class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string     :name, default: ''
      t.date       :completion_date
      t.datetime   :remind_at
      t.boolean    :completed, default: false

      t.references :user
      t.references :case
      t.references :case_note_domain_group
      t.references :domain

      t.timestamps
    end
  end
end
