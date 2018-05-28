namespace 'partner_list' do
  desc 'import and update referral source'
  task update: :environment do
    referral_sources = ReferralSource.pluck(:name)
    agencies         = Agency.pluck(:name)

    Organization.all.each do |org|
      Organization.switch_to org.short_name

      referral_sources.each do |rs|
        Partner.find_or_create_by(name: rs, type: 'referral source')
      end

      agencies.each do |agency|
        Partner.find_or_create_by(name: agency, type: 'agency')
      end

      Client.all.each do |client|
        if client.referral_source.present?
          referral_id = client.referral_source_id
          return unless referral_id.present?
          referral_name = ReferralSource.find_by(id: referral_id).try(:name)
          referral_id = Partner.find_by(name: referral_name).id
          client.update_columns(referral_source_id: referral_id)
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
