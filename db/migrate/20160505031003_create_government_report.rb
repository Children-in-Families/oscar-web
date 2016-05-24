class CreateGovernmentReport < ActiveRecord::Migration
  def change
    create_table :government_reports do |t|
    	t.string  :code, 													default: ''
    	t.string  :initial_capital, 							default: ''
    	t.string  :initial_city, 									default: ''
    	t.string  :initial_commune, 							default: ''
    	t.date 	  :initial_date
    	t.string  :client_code, 									default: ''
    	t.string  :commune, 											default: ''
    	t.string  :city, 													default: ''
    	t.string  :capital, 											default: ''
    	t.string  :organisation_name, 						default: ''
    	t.string  :organisation_phone_number, 		default: ''
    	t.string  :client_name, 									default: ''
    	t.date 	  :client_date_of_birth
    	t.string  :client_gender, 								default: ''
    	t.string  :found_client_at, 							default: ''
    	t.string  :found_client_village, 					default: ''
    	t.string  :education, 										default: ''
    	t.string  :carer_name, 										default: ''
    	t.string  :client_contact, 								default: ''
    	t.string  :carer_house_number, 						default: ''
    	t.string  :carer_street_number, 					default: ''
    	t.string  :carer_village, 								default: ''
    	t.string  :carer_commune, 								default: ''
    	t.string  :carer_city, 										default: ''
    	t.string  :carer_capital, 								default: ''
    	t.string  :carer_phone_number, 						default: ''
    	t.date    :case_information_date
    	t.string  :referral_name, 								default: ''
    	t.string  :referral_position, 						default: ''
    	t.boolean :anonymous, 										default: false
    	t.text	  :anonymous_description, 				default: ''
		t.boolean :client_living_with_guardian, 	default: false
		t.text 	  :present_physical_health, 			default: ''
		t.text 	  :physical_health_need, 					default: ''
		t.text 	  :physical_health_plan, 					default: ''
		t.text 	  :present_supplies, 							default: ''
		t.text 	  :supplies_need, 								default: ''
		t.text 	  :supplies_plan, 								default: ''
		t.text 	  :present_education, 						default: ''
		t.text 	  :education_need, 								default: ''
		t.text 	  :education_plan, 								default: ''
		t.text 	  :present_family_communication, 	default: ''
		t.text 	  :family_communication_need, 		default: ''
		t.text 	  :family_communication_plan, 		default: ''
		t.text 	  :present_society_communication, default: ''
		t.text 	  :society_communication_need, 		default: ''
		t.text 	  :society_communication_plan, 		default: ''
		t.text 	  :present_emotional_health, 			default: ''
		t.text 	  :emotional_health_need, 				default: ''
		t.text 	  :emotional_health_plan, 				default: ''
		t.boolean :mission_obtainable, 						default: false
		t.boolean :first_mission, 								default: false
		t.boolean :second_mission, 								default: false
		t.boolean :third_mission, 								default: false
		t.boolean :fourth_mission, 								default: false
		t.date 	  :done_date 
		t.date 	  :agreed_date    	

    	t.belongs_to :client

    	t.timestamps
    end
  end
end
