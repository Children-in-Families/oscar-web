class CreatePartners < ActiveRecord::Migration[5.2]
  def change
    create_table :partners do |t|
      t.string :name, default: ''
      t.string :address, default: ''
      t.date   :start_date
      t.string :contact_person_name, default: ''
      t.string :contact_person_email, default: ''
      t.string :contact_person_mobile, default: ''
      t.string :organisation_type, default: ''
      t.string :affiliation, default: ''
      t.string :engagement, default: ''
      t.text   :background, default: ''

      t.references :province

      t.timestamps
    end
  end
end
