namespace :default_csi_age do
  desc 'Update age in default CSI'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Setting.first.update_attributes(age: 18)
    end
  end
end
