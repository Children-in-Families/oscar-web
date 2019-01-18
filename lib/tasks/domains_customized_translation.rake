namespace :domains_customized_translation do
  desc 'Copy Custom Domains score definition and description to local score definition and description fields'
  task update: :environment do

    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Domain.custom_csi_domains.each do |domain|
        domain.update(
          local_description: domain.description,
          score_1_local_definition: domain.score_1_definition,
          score_2_local_definition: domain.score_2_definition,
          score_3_local_definition: domain.score_3_definition,
          score_4_local_definition: domain.score_4_definition,
        )
      end
    end
  end
end
