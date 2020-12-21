class ChangeAssessmentDomainScoreColumn < ActiveRecord::Migration[5.2]
  def change
  	change_column :assessment_domains, :score, :integer, :default => nil
  end
end
