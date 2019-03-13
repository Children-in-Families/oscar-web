namespace :users_gender do
  desc 'Set default gender to exiting users'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      User.where(gender: '').each do |user|
        user.update(gender: 'prefer not to say')
      end
    end
  end
end
