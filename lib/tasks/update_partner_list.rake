namespace 'partner_list' do
  desc 'import and update referral source'
  task update: :environment do

    Organization.all.each do |org|
      Organization.switch_to org.short_name

      ReferralSource.pluck(:name).uniq.each do |rs|
        partner = Partner.find_or_initialize_by(name: rs)
        next if 'referral source'.in? partner.partner_type
        partner.partner_type << 'referral source'
        partner.save
      end

      Agency.pluck(:name).uniq.each do |agency|
        partner = Partner.find_or_initialize_by(name: agency)
        next if 'agency'.in? partner.partner_type
        partner.partner_type << 'agency'
        partner.save
      end

      Client.all.each do |client|
        if client.referral_source_id.present?
          referral_id = client.referral_source_id
          return unless referral_id.present?
          referral_name = ReferralSource.find_by(id: referral_id).try(:name)
          partner_id = Partner.find_by(name: referral_name).id
          client.update_columns(referral_source_id: partner_id)
        end

        if client.agency_clients.present?
          agency_ids = AgencyClient.where(client_id: client.id).pluck(:agency_id)
          return unless agency_ids.any?
          ageny_names = Agency.where(id: agency_ids).pluck(:name)
          Partner.where(name: ageny_names).each do |partner|
            client.client_partners.create(partner_id: partner.id)
          end
        end
      end
    end
  end
end
