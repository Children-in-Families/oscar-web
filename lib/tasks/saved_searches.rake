namespace :saved_searches do
  desc "Update save search and remove"
  task update: :environment do
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name
      ProgramStream.all.each do |program_stream|
        program_stream.name
      end
    end
  end

  task delete: :environment do
  end
end
