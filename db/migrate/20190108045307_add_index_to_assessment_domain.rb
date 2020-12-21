class AddIndexToAssessmentDomain < ActiveRecord::Migration[5.2]
  def change
    add_index :assessment_domains, :score
  end
end
