class CaseNoteDomainGroupVersion
  def self.version(case_note_id, event)
    ids = CaseNoteDomainGroup.where(case_note_id: case_note_id).pluck(:id)
    PaperTrail::Version.where("item_id IN (?) AND event = ?", ids, event)
  end
end