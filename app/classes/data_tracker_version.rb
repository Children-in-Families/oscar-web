class DataTrackerVersion
  def self.assessment_domain(assessment_id, event)
    ad_ids = AssessmentDomain.where(assessment_id: assessment_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('item_id IN (?) AND item_type = ? AND event = ?', ad_ids, 'AssessmentDomain', event).order('created_at DESC')
  end

  def self.case_note(case_note_id, event)
    ids = CaseNoteDomainGroup.where(case_note_id: case_note_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('item_id IN (?) AND item_type = ? AND event = ?', ids, 'CaseNote', event)
  end

  def self.agency_and_quantitative_case(client_id, event)
    agency_ids = AgencyClient.where(client_id: client_id).pluck(:id)
    qc_ids     = ClientQuantitativeCase.where(client_id: client_id).pluck(:id)
    donor_ids  = Sponsor.where(client_id: client_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('(item_id IN (?) AND item_type = ?) OR (item_id IN (?) AND item_type = ?) OR (item_id IN (?) AND item_type = ?) AND event = ?', donor_ids, 'Sponsor', agency_ids, 'AgencyClient', qc_ids, 'ClientQuantitativeCase', event)
  end

  def self.tracking(program_stream_id, event)
    ids = Tracking.where(program_stream_id: program_stream_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('item_id IN (?) AND event = ? AND item_type = ?', ids, event, 'Tracking')
  end

  def self.client_enrollment_tracking(client_enrollment_id, event)
    ids = ClientEnrollmentTracking.where(client_enrollment_id: client_enrollment_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('item_id IN (?) AND event = ? AND item_type = ?', ids, event, 'ClientEnrollmentTracking')
  end

  def self.leave_program(client_enrollment_id, event)
    ids = LeaveProgram.where(client_enrollment_id: client_enrollment_id).pluck(:id)
    PaperTrail::Version.where.not(item_type: exclude_item_type).where('item_id IN (?) AND event = ? AND item_type = ?', ids, event, 'LeaveProgram')
  end

  private

  def self.exclude_item_type
    %w(ClientCustomField FamilyCustomField PartnerCustomField UserCustomField CaseWorkerTask Location EnterNgo ExitNgo Referral)
  end
end
