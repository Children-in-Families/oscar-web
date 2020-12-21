class CreateAssessmentDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_domains do |t|
      t.text :note, default: ''
      t.integer :previous_score
      t.integer :score, default: 3
      t.text    :reason, default: ''

      t.references :assessment
      t.references :domain

      t.timestamps
    end
  end
end
