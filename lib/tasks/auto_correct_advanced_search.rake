namespace :auto_correct_advanced_search do
  desc 'Auto correct existing advanced search records with id program_stream'
  task start: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      AdvancedSearch.all.each do |search|
        next if search.queries['rules'].empty?
        rules = AutoCorrectAdvancedSearch.new(search.queries['rules']).correct
        search.queries['rules'] = rules
        search.save
      end
    end
  end
end

class AutoCorrectAdvancedSearch
  def initialize(rules)
    @rules = rules
  end

  def correct
    @rules.each do |rule|
      if rule['rules'].present?
        AutoCorrectAdvancedSearch.new(rule['rules']).correct
      elsif rule['id'].present? && rule['id'] == 'program_stream' && rule['field'].present? && rule['field'] == 'program_stream'
        rule['id'] = 'active_program_stream'
        rule['field'] = 'active_program_stream'
      end
    end
  end
end
