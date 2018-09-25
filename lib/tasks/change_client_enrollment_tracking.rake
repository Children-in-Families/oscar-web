namespace :client_enrollment_tracking do
  desc "Change Client Enrollment Tracking's Value of Tracknig 81"
  task change: :environment do
    Organization.switch_to 'cfi'
    program = ProgramStream.find 26
    trackings = ClientEnrollmentTracking.where(tracking_id: program.trackings.first.id)
    trackings.each do |tracking|
      value = tracking.properties["ចំណាត់ថ្នាក់ប្រចាំខែ-ឆមាស-ឆ្នាំ/Monthly-Bi-annually-Annually Rank:"].first
      if value == 'N/A'
        tracking.properties["ចំណាត់ថ្នាក់ប្រចាំខែ-ឆមាស-ឆ្នាំ/Monthly-Bi-annually-Annually Rank:"] = '0'
      else
        tracking.properties["ចំណាត់ថ្នាក់ប្រចាំខែ-ឆមាស-ឆ្នាំ/Monthly-Bi-annually-Annually Rank:"] = value
      end
      tracking.save
    end
  end
end
