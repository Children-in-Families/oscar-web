namespace :usage_report do
  desc "Rebuild usage report"
  task :rebuild, [:short_name] => :environment do |task, args|
    if args.short_name
      org = Organization.find_by!(short_name: args.short_name)
      rebuild_report(org)
    else
      Organization.without_shared.each do |org|
        begin
          rebuild_report(org)
        rescue ActiveRecord::StatementInvalid => e
          puts "===================== error on schema #{org.short_name} ====================================="
          puts e.message
          puts "===================== Skipping ====================================="
        end
      end
    end
  end

  desc "Build latest usage report"
  task :build_latest, [:short_name] => :environment do |task, args|
    if args.short_name
      org = Organization.find_by!(short_name: args.short_name)
      UsageReportBuilder.call(org, 1.month.ago.month, 1.month.ago.year)
    else
      Organization.without_shared.each do |org|
        UsageReportBuilder.call(org, 1.month.ago.month, 1.month.ago.year)
      end
    end
  end

  desc "Build latest usage report with dummy data"
  task :build_latest_dummy, [:short_name] => :environment do |task, args|
    puts "=====================rebuilding report on schema #{args.short_name} ====================================="
    UsageReportBuilder.call(Organization.find_by(short_name: args.short_name), 1.month.ago.month, 1.month.ago.year, true, true)
  end
end

def rebuild_report(org)
  puts "=====================rebuilding report on schema #{org.short_name} ====================================="

  (org.created_at.year..Time.zone.today.year).to_a.each do |year|
    (1..12).to_a.each do |month|
      next if year == Date.current.year && month >= Date.current.month
      UsageReportBuilder.call(org, month, year, true)
    end
  end
end
