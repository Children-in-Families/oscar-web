namespace :referee_carer do
  desc "Update Referee Carer in client"
  task update: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      puts "#{org.short_name} Starting..."
      referee_results = Client.where.not(referee_id: nil).map.each do |client|
        "(#{client.referee_id}, '#{client.referral_phone && client.referral_phone.gsub("'", "''")}')"
      end.uniq.join(", ")

      referee_results = Client.where.not(carer_id: nil).map.each do |client|
        "(#{client.carer_id}, '#{client.telephone_number && client.telephone_number.gsub("'", "''")}')"
      end.uniq.join(", ")

      sql = <<-SQL.squish
        UPDATE referees SET phone = mapping_values.phone FROM (VALUES #{referee_results}) AS mapping_values (referee_id, phone) WHERE referees.id = mapping_values.referee_id;
        UPDATE carers SET phone = mapping_values.phone FROM (VALUES #{referee_results}) AS mapping_values (carer_id, phone) WHERE carers.id = mapping_values.carer_id;
      SQL
      ActiveRecord::Base.connection.execute(sql) if referee_results.present? || referee_results.present?
    end
  end

end
