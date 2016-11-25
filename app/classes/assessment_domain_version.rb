class AssessmentDomainVersion
  def self.version(assessment_id, event)
    ad_ids = AssessmentDomain.where(assessment_id: assessment_id).pluck(:id)
    PaperTrail::Version.where("item_id IN (?) AND event = ?", ad_ids, event)
  end
end