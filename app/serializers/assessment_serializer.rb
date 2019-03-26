class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :client_id, :created_at, :updated_at, :case_notes, :completed, :default, :assessment_domain

  # has_many :assessment_domains

  def case_notes
    ActiveModel::ArraySerializer.new(object.case_notes, each_serializer: CaseNoteSerializer)
  end

  def assessment_domain
   object.assessment_domains
  end
end
