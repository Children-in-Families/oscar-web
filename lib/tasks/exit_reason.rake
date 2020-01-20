namespace :exit_reason do
  desc "Correct the exit reasons for clients"
  task correct: :environment do
    reasons = {:agency_lack_resource=>"Agency lacks sufficient resources", :client_died=>"Client died", :client_refuse_service=>"Client refused service", :move_out_within_cambodia=>"Client is/moved outside NGO target area (within Cambodia)", :move_out_within_international=>"Client is/moved outside NGO target area (International)", :no_meet_service_criteria=>"Client does not meet / no longer meets service criteria", :not_required_support=>"Client does not require / no longer requires support", :other_reason=>"Other"}
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      values = ExitNgo.joins(:client).where(created_at: ['2019-07-03'..'2020-01-16']).map do |exit_ngo|
        exit_reasons = exit_ngo.exit_reasons.map do |reason|
          correct_reason = [ExitNgo::EXIT_REASONS, reasons.values].transpose.to_h[reason]
        end
        exit_ngo.exit_reasons = exit_reasons

        "(#{exit_ngo.id}, ARRAY['#{exit_ngo.exit_reasons.join("','")}'])"
      end.join(", ")
      sql = "
        UPDATE #{short_name}.exit_ngos SET exit_reasons = mapping_values.reasons FROM (VALUES #{values}) AS mapping_values (exit_ngo_id, reasons) WHERE #{short_name}.exit_ngos.id = mapping_values.exit_ngo_id;
      ".squish

      if values.present?
        ActiveRecord::Base.connection.execute(sql)
        puts "#{short_name}: Done correcting exit_reasons!!!"
      end
    end
  end
end
