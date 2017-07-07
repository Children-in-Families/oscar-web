class AddAttachmentsToAssessmentDomain < ActiveRecord::Migration
  def change
    add_column :assessment_domains, :attachments, :string, array: true, default: []
  end
end
