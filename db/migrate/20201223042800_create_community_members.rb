class CreateCommunityMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :community_members do |t|
      t.string   "name",                              default: ""
      t.references  "community", foreign_key: true
      t.references  "family", foreign_key: true
      t.string   "gender"
      t.string   "role"

      t.integer  "adule_male_count"
      t.integer  "adule_female_count"
      t.integer  "kid_male_count"
      t.integer  "kid_female_count"

      t.timestamps
    end
  end
end
