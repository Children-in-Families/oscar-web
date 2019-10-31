class CreateCallers < ActiveRecord::Migration
  def change
    create_table :callers do |t|
      t.boolean :answered_call, default: false
      t.boolean :anonymous, default: false
      t.boolean :adult, default: false

      t.string :name, default: ''
      t.string :gender, default: ''
      t.string :referee_phone_number, default: ''
      t.string :referee_email, default: ''

      t.integer :referral_source_category_id
      t.integer :referral_source_id

      t.references :province
      t.references :district
      t.references :commune
      t.references :village

      t.string :street_number, default: ''
      t.string :house_number, default: ''
      t.string :address_name, default: ''
      t.string :address_type, default: ''

      t.boolean :requested_update

      t.timestamps null: false
    end
  end
end
