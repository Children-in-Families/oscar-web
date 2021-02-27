class AddCarePlanToAssessmentDomain < ActiveRecord::Migration
  def change
    add_reference :assessment_domains, :care_plan, index: true, foreign_key: true
  end
end
