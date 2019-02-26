class AddIndexToAssessmentDomain < ActiveRecord::Migration
  def change
    add_index :assessment_domains, :score
  end
end
