class IndexForeignKeysInAssessmentDomains < ActiveRecord::Migration
  def change
    add_index :assessment_domains, :assessment_id
    add_index :assessment_domains, :domain_id
  end
end
