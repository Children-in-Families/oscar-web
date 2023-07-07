class RefereeSerializer < ActiveModel::Serializer
<<<<<<< HEAD
  attributes  :id, :name, :address_type, :outside, :current_address, :email,
              :gender, :house_number, :outside_address, :street_number,
              :phone, :adult, :suburb, :description_house_landmark,
              :directions, :street_line1, :street_line2, :plot, :anonymous,
=======
  attributes  :id, :name, :address_type, :current_address, :email,
              :gender, :house_number, :outside_address, :street_number,
              :phone, :adult, :suburb, :description_house_landmark,
              :directions, :street_line1, :street_line2, :plot,
>>>>>>> 8ccf9b407 (Update API V1)
              :road, :postal_code, :state_id, :township_id, :subdistrict_id, :locality,
              :province_id, :district_id, :commune_id, :village_id
end
