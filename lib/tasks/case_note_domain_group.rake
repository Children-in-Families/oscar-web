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
end

def enable_default_assessment?
  setting = Setting.first
  setting && setting.enable_default_assessment
end
