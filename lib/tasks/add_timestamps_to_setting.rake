namespace :add_timestamps_to_setting do
  desc 'Set timestamps to existing settings'
  task set: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Setting.where(created_at: nil, updated_at: nil).each do |setting|
        created_at = setting.versions.first.try(:created_at) || Time.now
        setting.update(created_at: created_at, updated_at: created_at)
      end
    end
  end
end
