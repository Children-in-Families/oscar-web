class DataTrackerVersion
  def self.assessment_domain(assessment_id, event)
    ad_ids = AssessmentDomain.where(assessment_id: assessment_id).pluck(:id)
    PaperTrail::Version.where('item_id IN (?) AND event = ?', ad_ids, event).order('created_at DESC')
  end

  def self.case_note(case_note_id, event)
    ids = CaseNoteDomainGroup.where(case_note_id: case_note_id).pluck(:id)
    PaperTrail::Version.where('item_id IN (?) AND event = ?', ids, event)
  end

  def self.agency_and_quantitative_case(client_id, event)
    agency_ids = AgencyClient.where(client_id: client_id).pluck(:id)
    qc_ids = ClientQuantitativeCase.where(client_id: client_id).pluck(:id)
    PaperTrail::Version.where('item_id IN (?) AND item_type = ? OR item_id IN (?) AND item_type = ? AND event = ?', agency_ids, 'AgencyClient', qc_ids, 'ClientQuantitativeCase', event)
  end
end
