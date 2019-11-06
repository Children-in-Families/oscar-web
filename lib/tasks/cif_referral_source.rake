namespace :cif_referral_source do
  desc "Restore the referral back to original name and create new the current name"
  task restore: :environment do
    Organization.switch_to 'cif'
    PaperTrail::Version.where(item_type: 'ReferralSource', whodunnit: '96', event: 'update').where("date(versions.created_at) <= '2019-11-05'").map(&:changeset).each do |changes|
      binding.pry
      changes
    end
  end

end
