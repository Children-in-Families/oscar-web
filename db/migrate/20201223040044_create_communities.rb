class CreateCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :communities do |t|
      t.integer  "received_by_id"
      t.date     "initial_referral_date"

      t.references  "referral_source", foreign_key: true
      t.integer  "referral_source_category_id"

      t.string   "name",                            default: ""
      t.string   "name_en"
      t.date     "formed_date"

      t.references  "province", foreign_key: true
      t.references  "district", foreign_key: true
      t.references  "commune", foreign_key: true
      t.references  "village", foreign_key: true

      t.string   "representative_name"
      t.string   "gender"
      t.string   "role"
      t.string   "phone_number"

      t.text     "relevant_information"
      t.string   "documents",                       default: [],        array: true

      t.datetime "deleted_at"
      t.string   "status",                          default: ""
      t.references  "user", foreign_key: true

      t.timestamps
    end
  end
end
