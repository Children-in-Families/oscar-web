namespace :exit_reason do
  desc "Correct the exit reasons for clients"
  task correct: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      ExitNgo.joins(:client).map do |exit_ngo|
        binding.pry
      end
    end
  end
end
