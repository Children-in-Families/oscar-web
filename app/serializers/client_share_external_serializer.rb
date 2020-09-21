class ClientShareExternalSerializer < ActiveModel::Serializer
  attributes  :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :global_id, :slug, :external_id, :external_id_display, :mosvy_number, :location_current_village_code


  def location_current_village_code
    object.village_code || object.commune_code || object.district_code || ""
  end

  def external_id
    object.external_id || ""
  end

  def external_id_display
    object.external_id_display || ""
  end

  def mosvy_number
    object.mosvy_number || ""
  end
end
