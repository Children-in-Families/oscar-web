class DuplicateCheckerWorker
  include Sidekiq::Worker

  def perform(client_id, tenant)
    Organization.switch_to tenant

    client = Client.find_by(id: client_id)
    return if client.blank?

    duplicate_checker_fields = {
      slug: client.slug,
      given_name: client.given_name ,
      family_name: client.family_name,
      local_given_name: client.local_given_name,
      local_family_name: client.local_family_name,
      date_of_birth: client.date_of_birth,
      birth_province_id: client.birth_province_id,
      current_province_id: client.province_id,
      district_id: client.district_id,
      village_id: client.village_id,
      commune_id: client.commune_id,
      gender: client.gender
    }


    duplicate_response = Client.find_shared_client(duplicate_checker_fields)
    archived_slug = duplicate_response[:duplicate_with]

    if archived_slug
      tenant, client_id = archived_slug.split('-')
      duplicate_with_client = Apartment::Tenant.switch(tenant) { Client.find(client_id) }

      client.update_columns(duplicate: true, duplicate_with: {
        duplicated_with_client_id: duplicate_with_client.slug,
        duplicated_with_ngo: tenant,
        duplicate_fields: duplicate_response[:similar_fields].map{ |field| field.gsub(/#hidden_|_fields/, "") }
      })
    else
      client.update_columns(duplicate: false, duplicate_with: {})
    end
  end
end
