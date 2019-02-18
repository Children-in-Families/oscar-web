namespace :cambodia_tenant_data do
  desc "Update Cambodian sharing data to true"
  task share: :environment do |task, args|
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      Setting.update_all(sharing_data: true)
    end
  end
end
