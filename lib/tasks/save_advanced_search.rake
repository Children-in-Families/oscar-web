namespace :save_advanced_search do
  desc "Update save advanced search..."
  task update: :environment  do
    Organization.all.pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      AdvancedSearch.all.each do |ads|
        queries = ads.queries
        next if queries.blank?
        query_rules = queries['rules'].each do |query|
          begin
            next if query['rules'].present?
            next if query['input'] == 'select'
            next if query['operator'] == 'between'

            puts "#{short_name} >>>> ads_id: #{ads.id}"
            puts query
            query['id'] = query['id'].gsub(/\_+/, '__')
            query['field'] = query['field'].gsub(/\_+/, '__')
          rescue Exception => e
            puts e
          end
        end
        queries['rules'] = query_rules
        ads.queries = queries
        ads.save
      end
    end
  end
end
