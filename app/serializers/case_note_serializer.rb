class CaseNoteSerializer < ActiveModel::Serializer
  attributes :id, :present, :date, :case_note_domain_groups_attributes

  def  case_note_domain_groups_attributes
    object.case_note_domain_groups
  end
end
