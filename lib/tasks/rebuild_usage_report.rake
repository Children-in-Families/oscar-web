namespace :usage_report do
  desc "Rebuild usage report"
  task :rebuild, [:short_name] => :environment do |task, args|
    if args.short_name
      org = Organization.find_by!(short_name: args.short_name)
      rebuild_report(org)
    else
      Organization.without_shared.each do |org|
        rebuild_report(org)
      end
    end
  end
end

def rebuild_report(org)
  puts "=====================rebuilding report on schema #{org.short_name} ====================================="
  
  (org.created_at.year..Time.zone.today.year).to_a.each do |year|
    (1..12).to_a.each do |month|
      next if year == Date.current.year && month >= Date.current.month
      
      puts "=====================rebuilding report on schema #{org.short_name} for #{month}/#{year} ====================================="
      UsageReportBuilder.call(org, month, year, true)
    end
  end
end
