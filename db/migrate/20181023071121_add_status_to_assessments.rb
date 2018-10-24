class AddStatusToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :completed, :boolean, default: false

    unprocessable_assessments = []

    puts '========== Processing =========='

    Assessment.all.each do |assessment|
      begin
        assessment.update_attributes!(completed: true) if assessment.assessment_domains.where(goal: '', score: nil, reason: '').count.zero?
      rescue
        unprocessable_assessments << assessment.id
        puts "===== error assessment id #{assessment.id} ====="
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_assessments} >> error.txt" if unprocessable_assessments.present?
  end
end
