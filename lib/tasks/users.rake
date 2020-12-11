namespace :users do
  desc "Remind Case Worker incomplete overdue tasks weekly"
  task remind: :environment do
    user_reminder = UserReminder.new
    user_reminder.remind
  end
end
