namespace :program_stream do
  desc 'Update Program Stream Name'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ProgramStream.all.each do |program_stream|
        program_stream.update(name: program_stream.name.squish)
      end
    end
  end
end
