namespace :ratanak do
  desc "Change score header in the description to the actual score title on the score section for all of Ratanak's domains"
  task fix_domain_data: :environment do
    Organization.switch_to 'ratanak'

    Domain.find_each do |domain|
      # Def 1
      description = domain.description.gsub("<strong>No awareness:</strong>", "<strong>#{domain.score_1_definition}</strong>")
      local_description = domain.local_description.gsub("<strong>គ្មានការយល់ដឹង៖</strong>", "<strong>#{domain.score_1_local_definition}</strong>")

      # Def 2
      description = description.gsub("<strong>Knowledge and awareness:</strong>", "<strong>#{domain.score_2_definition}</strong>")
      local_description = local_description.gsub("<strong>ចំណេះដឹងនិងការយល់ដឹង៖</strong>", "<strong>#{domain.score_2_local_definition}</strong>")

      # Def 3
      description = description.gsub("<strong>Developing plans and positive coping strategies:</strong>", "<strong>#{domain.score_3_definition}</strong>")
      local_description = local_description.gsub("<strong>ការរៀបចំផែនការនិងយុទ្ធសាស្រ្តដោះស្រាយវិជ្ជមាន៖</strong>", "<strong>#{domain.score_3_local_definition}</strong>")

      # Def 4
      description = description.gsub("<strong>Stability and competence:</strong>", "<strong>#{domain.score_4_definition}</strong>")
      local_description = local_description.gsub("<strong>ស្ថេរភាពនិងសមត្ថភាព៖</strong>", "<strong>#{domain.score_4_local_definition}</strong>")

      domain.update_columns(description: description, local_description: local_description)
    end
  end
end
