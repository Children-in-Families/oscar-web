class AddStatusToAssessments < ActiveRecord::Migration
  def up
    add_column :assessments, :completed, :boolean, default: false

    unprocessable_assessments = []

    puts '========== Processing =========='

    Assessment.all.each do |assessment|
      begin
        if assessment.assessment_domains.where(goal: '', score: nil, reason: '').count.zero?
          assessment.completed = true
          assessment.save(validate: false)
        end
      rescue
        unprocessable_assessments << assessment.id
        puts "===== error assessment id #{assessment.id} ====="
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_assessments} >> error_#{Organization.current.short_name}.txt" if unprocessable_assessments.present?
  end

  def down
    remove_column :assessments, :completed, :boolean, default: false
  end
end
