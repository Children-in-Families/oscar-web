class RefereeSerializer < ActiveModel::Serializer
  attributes  :id, :name, :address_type, :current_address, :email,
              :gender, :house_number, :outside_address, :street_number,
              :phone, :adult, :suburb, :description_house_landmark,
              :directions, :street_line1, :street_line2, :plot,
              :road, :postal_code, :state_id, :township_id, :subdistrict_id, :locality,
              :province_id, :district_id, :commune_id, :village_id
end
