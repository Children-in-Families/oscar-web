class CarerSerializer < ActiveModel::Serializer
  attributes  :id, :name, :address_type, :current_address, :email, :gender, :house_number, :outside_address,
              :street_number, :client_relationship, :outside, :postal_code,
              :phone, :same_as_client, :suburb, :description_house_landmark,
              :directions, :street_line1, :street_line2, :plot, :road, :locality,
              :state_id, :township_id, :subdistrict_id,
              :province_id, :district_id, :commune_id, :village_id
end
