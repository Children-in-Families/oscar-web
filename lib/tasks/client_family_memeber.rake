namespace :client_family_memeber do
  desc "Re attach family to client"
  task re_attach: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Client.includes(:family_member).where(family_members: { id: nil }).where.not(current_family_id: nil).distinct.each do |client|
        client.create_family_member(family_id: client.current_family_id, gender: client.gender, date_of_birth: client.date_of_birth)
      end
      puts "Re-attach NGO #{org.short_name}"
    end
    puts "Re-attach done!!!"
  end

end
