namespace :incompleted_assessment do
  desc "Delete incompleted assessment after one week of creation"
  task delete: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'

      Organization.switch_to org.short_name

      setting = Setting.first_or_initialize
      next if setting.never_delete_incomplete_assessment?

      Assessment.incompleted.where("created_at < ?", setting.delete_incomplete_after_period.ago).delete_all
    end

    puts 'Incompleted assesssment deleted!!!'
  end
end
