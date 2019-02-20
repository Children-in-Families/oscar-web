namespace :oscar_team_permission do
  desc 'enable log in to OSCaR Gov and Research'
  task grant: :environment do
    user = User.find_by(email: ENV['OSCAR_TEAM_EMAIL'])
    user.update(enable_gov_log_in: true, enable_research_log_in: true)
  end
end