class AssessmentSerializer < ActiveModel::Serializer
  attributes :id, :client_id, :family_id, :created_at, :updated_at, :case_notes, :completed, :default, :assessment_domain

  def case_notes
    ActiveModel::ArraySerializer.new(object.case_notes, each_serializer: CaseNoteSerializer)
  end

  def assessment_domain
    object.assessment_domains_in_order.map do |ad|
      incomplete_tasks = object.parent.tasks.by_domain_id(ad.domain_id).incomplete
      incomplete_tasks_with_domain = incomplete_tasks.includes(:domain).map { |task| task.as_json(only: [:id, :name, :completion_date]).merge(domain: task.domain.as_json(only: [:id, :name, :identity])) }
      ad.as_json.merge(domain: ad.domain.as_json(only: [:name, :identity]), incomplete_tasks: incomplete_tasks_with_domain)
    end
  end
end
