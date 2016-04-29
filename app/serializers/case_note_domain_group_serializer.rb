class CaseNoteDomainGroupSerializer < ActiveModel::Serializer
  attributes :note, :case_note_id, :domain_group_id, :id

  has_many :tasks
end
