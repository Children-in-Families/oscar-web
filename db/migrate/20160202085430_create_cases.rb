class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases do |t|
      t.date    :start_date
      t.string  :carer_names, default: ''
      t.string  :carer_address, default: ''
      t.string  :carer_phone_number, default: ''
      t.float   :support_amount, default: 0
      t.text    :support_note, default: ''
      t.text    :case_type, default: 'EC'

      t.boolean :exited, default: false
      t.date    :exit_date
      t.text    :exit_note, default: ''

      t.references :user
      t.references :client
      t.references :family
      t.references :partner
      t.references :province

      t.timestamps
    end
  end
end
