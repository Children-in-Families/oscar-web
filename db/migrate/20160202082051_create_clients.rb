class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :code, default: ''
      t.string :first_name, default: ''
      t.string :last_name, default: ''
      t.string :gender, default: 'Male'
      t.date   :date_of_birth
      t.string :status, default: 'Referred'
      t.date   :initial_referral_date
      t.string :referral_phone, default: ''

      t.integer :birth_province_id
      t.integer :received_by_id
      t.integer :followed_up_by_id

      t.date :follow_up_date

      t.string :current_address, default: ''
      t.string :school_name, default: ''
      t.string :school_grade, default: ''
      t.boolean :has_been_in_orphanage, default: false
      t.boolean :able, default: false
      t.boolean :has_been_in_government_care, default: false
      t.text    :relevant_referral_information, default: ''

      t.string  :state, default: ''
      t.text    :rejected_note, default: ''

      t.references :province
      t.references :referral_source
      t.references :user

      t.timestamps
    end
  end
end
