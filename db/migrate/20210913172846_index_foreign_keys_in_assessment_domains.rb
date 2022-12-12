class IndexForeignKeysInAssessmentDomains < ActiveRecord::Migration[5.2]
  def change
    add_index :assessment_domains, :assessment_id unless index_exists? :assessment_domains, :assessment_id
    add_index :assessment_domains, :domain_id unless index_exists? :assessment_domains, :domain_id
  end
end
