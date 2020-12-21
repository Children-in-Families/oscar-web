class AddAttachmentsToAssessmentDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_domains, :attachments, :string, array: true, default: []
  end
end
