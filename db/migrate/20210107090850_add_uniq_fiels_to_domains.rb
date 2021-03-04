class AddUniqFielsToDomains < ActiveRecord::Migration
  def change
    if schema_search_path =~ /^\"isf\"/
      reversible do |dir|
        dir.up do
          Domain.joins(:assessment_domains).order('domains.id').distinct.map{|domain| [domain.id, domain.name, domain.identity] }.group_by{|domain| "#{domain.second} #{domain.third}" }.each do |group|
            custom_domain_1, custom_domain_2 = group.second.map(&:first)
            AssessmentDomain.where(domain_id: custom_domain_2).update_all(domain_id: custom_domain_1)
            Task.with_deleted.where(domain_id: custom_domain_2).update_all(domain_id: custom_domain_1)
            DomainProgramStream.where(domain_id: custom_domain_2).update_all(domain_id: custom_domain_1)
            domain = Domain.find(custom_domain_2)
            domain.delete if domain.tasks.with_deleted.blank? && domain.assessment_domains.blank? && domain.domain_program_streams.blank?
          end
        end
      end
    end
    add_index :domains, %i[name identity custom_assessment_setting_id domain_type], unique: true, name: 'index_domains_on_name_identity_custom_setting_domain_type'
  end
end
