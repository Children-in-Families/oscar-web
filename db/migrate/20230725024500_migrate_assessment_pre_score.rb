class MigrateAssessmentPreScore < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Assessment.where("created_at >= ?", "2023-07-17").order(:created_at).each do |assessment|
          if assessment.present? && !assessment.initial?
            if assessment.default?
              previous_assessment = assessment.parent.assessments.defaults.not_draft.joins(:assessment_domains).where("assessments.id < ?", assessment.id).order(id: :desc).first
            else
              previous_assessment = assessment.parent.assessments.customs.not_draft.joins(:assessment_domains).where("assessments.id < ?", assessment.id).order(id: :desc).first
            end

            if previous_assessment.present?
              previous_assessment.assessment_domains.each do |previous_assessment_domain|
                assessment.assessment_domains.each do |assessment_domain|
                  next if previous_assessment_domain.score.blank? || assessment_domain.previous_score.present?

                  puts "Update assessment domain previous_score #{assessment_domain.id}"

                  assessment_domain.previous_score = previous_assessment_domain.score if assessment_domain.domain_id == previous_assessment_domain.domain_id

                  assessment_domain.save(validate: false)
                end
              end
            end
          end
        end
      end
    end
  end
end
