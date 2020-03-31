namespace :case_note_domain_group do
  desc "create domain group for case notes did not have domains"
  task create: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      none_domain_case_notes = CaseNote.where.not(id: CaseNote.joins(:domain_groups).distinct.ids)
      next if none_domain_case_notes.blank?
      none_assessment = (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment)) || CustomAssessmentSetting.first.nil?
      if enable_default_assessment? || none_assessment
        none_domain_case_notes.each do |ndcn|
          DomainGroup.all.each do |dg|
            ndcn.case_note_domain_groups.create!(domain_group_id: dg.id)
          end
        end
      else
        custom_domains = CustomAssessmentSetting.first
        next if custom_domains.nil?
        none_domain_case_notes.each do |ndcn|
          domain_group_ids = custom_domains.domains.pluck(:domain_group_id).uniq
          domain_group_ids.each do |domain_group_id|
            ndcn.case_note_domain_groups.create(domain_group_id: domain_group_id)
          end
        end
      end
      puts short_name
      puts none_domain_case_notes.map{|cn| cn.client.slug }.join(', ')
    end
  end


  task auto_select: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      CaseNote.where(custom: true).where.not(custom_assessment_setting_id: nil).update_all(custom_assessment_setting_id: CustomAssessmentSetting.first&.id) if CustomAssessmentSetting.count == 1
      puts short_name
      casenote_values = CaseNote.limit.map do |case_note|
        next if case_note.selected_domain_group_ids.present?
        domain_group_ids = []
        domain_groups = case_note.case_note_domain_groups.where("attachments != '{}' OR note != ''")
        if case_note.assessment
          domain_group_ids = case_note.assessment.assessment_domains.map do |assessment_domain|
                              assessment_domain.domain.domain_group.id if assessment_domain.goal?
                            end
        else
          domain_group_ids = domain_groups.joins(:domain_group).pluck('domain_groups.id').uniq
        end
        next if domain_groups.blank?
        putc "."
        "(#{case_note.id}, ARRAY#{domain_group_ids.compact.uniq})"
      end.compact.join(', ')
      puts "done!!!"
      sql = "UPDATE case_notes SET selected_domain_group_ids = mapping_values.domain_group_ids FROM (VALUES #{casenote_values}) AS mapping_values (case_note_id, domain_group_ids) WHERE case_notes.id = mapping_values.case_note_id;".squish
      ActiveRecord::Base.connection.execute(sql) if casenote_values.present?
    end
  end
end

def enable_default_assessment?
  setting = Setting.first
  setting && setting.enable_default_assessment
end
