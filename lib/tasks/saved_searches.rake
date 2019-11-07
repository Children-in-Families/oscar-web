namespace :saved_searches do
  desc "Update rule in save search"
  task update: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name
      saved_searches = AdvancedSearch.all
      saved_searches.each do |ss|
        queries         = ss.queries
        updated_queries = get_rules(queries,ss)
      end
    end
  end

  desc "Remove rule from save search"
  task delete: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name
      saved_searches = AdvancedSearch.all
      saved_searches.each do |ss|
        queries = ss.queries
        remove_rules = remove_rules(queries, ss)
      end
    end
  end
end

private
  def remove_rules(queries, ss)
    program_stream_ids_updated = ProgramStream.ids
    if ss.program_streams.present?
      class_eval(ss.program_streams).each do |ps_id|
        next if class_eval(ss.program_streams).size == 1
        queries["rules"].each do |rule|
          if rule["id"].present?
            next unless program_stream_ids_updated.include?(ps_id)
            program_stream_name     = ProgramStream.find(ps_id).name
            program_stream_old_name = rule["id"]&.slice(/\__.*__/)&.gsub(/__/i,'')&.gsub(/\(|\)/i,'')&.squish
            if program_stream_old_name.present? && program_stream_name[/#{program_stream_old_name[0..5]}.*#{program_stream_old_name[-4]}/i]
              queries["rules"] = []
              queries["rules"] << rule
              ss.save
            end
          end
        end
      end
    end
  end

  def get_rules(queries,ss)
    program_stream_id = ProgramStream.ids
    if ss.program_streams.present?
      if !(program_stream_id & class_eval(ss.program_streams)).empty?
        class_eval(ss.program_streams).each do |ps_id|
          next unless program_stream_id.include?(ps_id)
          updated_queries = ProgramStream.find(ps_id)
          program_stream_updated_queries = updated_queries.name
          enrollment_updated_queries     = updated_queries.enrollment
          queries["rules"].each do |rule|
            program_stream_old_queries = get_rules(rule, ss) if rule.has_key?('rules')
            if rule["id"].present?
              program_stream_old_queries = rule["id"]&.slice(/\__.*__/)&.gsub(/__/i,'')&.gsub(/\(|\)/i,'')&.squish
              if program_stream_old_queries.present? && program_stream_updated_queries[/#{program_stream_old_queries[0..5]}.*#{program_stream_old_queries[-4]}/i]
                query_rule = rule["id"].sub(/__.*__/, "__#{program_stream_updated_queries}__")
                rule['id'] = query_rule
                ss.save
                enrollment_updated_queries.each do |enrollment|
                  updated_enrollment = enrollment["label"]
                  old_enrollment = rule["id"].gsub(/.*__/i,'')
                  if updated_enrollment[/#{old_enrollment[0..5]}.*#{old_enrollment[-4]}/i]
                    query_rule_enrollment = rule["id"].slice(/.*__/i) + updated_enrollment
                    rule['id'] = query_rule_enrollment
                    ss.save
                  end
                end
              end
            end
          end
        end
      end
    end
  end


