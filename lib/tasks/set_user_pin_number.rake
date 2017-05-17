namespace :users do
  desc "Set pin number to every user"
  task update: :environment do
    Organization.without_demo.each do |org|
      Organization.switch_to(org.short_name)
      User.all.each do |user|
        user.set_pin_number
        user.save
      end
    end
  end
end