class CreateCommunityQuantitativeCases < ActiveRecord::Migration
  def change
    create_table :community_quantitative_cases do |t|
      t.references  "quantitative_case", foreign_key: true
      t.references  "community", foreign_key: true

      t.timestamps
    end
  end
end
