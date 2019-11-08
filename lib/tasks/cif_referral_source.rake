namespace :cif_referral_source do
  desc "Restore the referral back to original name and create new the current name"
  task restore: :environment do
    Organization.switch_to 'cif'
    PaperTrail::Version.where(item_type: 'ReferralSource', event: 'update').where("date(versions.created_at) <= '2019-11-05'").each do |version|
      next unless version.changeset[:updated_at].last >= '2019-10-01'.to_date
      next if !version.changeset.has_key?(:ancestry)
      referral_source = ReferralSource.find(version.item_id)
      new_referral_name = referral_source.name
      referral_source.name = version.changeset[:name].first
      referral_source.ancestry = version.changeset[:ancestry].first
      referral_source.save

      ReferralSource.find_or_create_by(name: version.changeset[:name].last, ancestry: version.changeset[:ancestry].last)
    end
  end

end
