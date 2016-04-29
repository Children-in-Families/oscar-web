class ChangeAssessmentDomainScoreColumn < ActiveRecord::Migration
  def change
  	change_column :assessment_domains, :score, :integer, :default => nil
  end
end
