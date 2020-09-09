class ClientShareExternalSerializer < ActiveModel::Serializer
  attributes  :id, :given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :location_current_village_code


  def location_current_village_code
    object.village_code || object.commune_code || object.district_code
  end
end
