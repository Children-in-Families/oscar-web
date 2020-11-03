namespace :ngo_referral_souce_category do
  desc "Clean Demo referral source categories"
  task clean: :environment do
    Organization.oscar.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch! short_name
      referral_sources = ReferralSource.where("LOWER(name) ILIKE ?", "demo%")
      referral_sources.destroy_all if referral_sources.present?
    end
  end

  desc "Setup category name for each ngo"
  task setup: :environment do
    Organization.all.each do |org|
      Apartment::Tenant.switch! org.short_name
      referral_source = ReferralSource.find_by(name: "#{org.full_name} - OSCaR Referral")
      if referral_source.present? && referral_source.ancestry.present?
        referral_source_category = ReferralSource.find_by(ancestry: referral_source.ancestry)
        Organization.current.update_attributes(referral_source_category_name: referral_source_category.name_en) if referral_source_category
        puts "===========#{org.short_name}=================="
      end
    end
  end

end
