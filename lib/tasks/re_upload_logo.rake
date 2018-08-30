namespace :reupload_logo do
  desc 're-upload logo'
  task upload: :environment do |task, args|
    records = Organization.visible.pluck(:short_name, :logo).map { |org| {short_name: org[0], logo: org[1]} }
    records.each do |record|
      org = Organization.find_by(short_name: record[:short_name])
      if org.logo
        org.update(logo: File.open(Rails.root.join("app/assets/images/#{record[:logo]}")))
        org.logo.recreate_versions!
      end
    end
  end
end
