class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.references :case

      t.timestamps
    end
  end
end
