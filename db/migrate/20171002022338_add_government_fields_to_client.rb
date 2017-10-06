class AddGovernmentFieldsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :gov_city, :string, default: ''
    add_column :clients, :gov_commune, :string, default: ''
    add_column :clients, :gov_district, :string, default: ''

    add_column :clients, :gov_date, :date
    add_column :clients, :gov_village_code, :string, default: ''
    add_column :clients, :gov_client_code, :string, default: ''

    add_column :clients, :gov_interview_village, :string, default: ''
    add_column :clients, :gov_interview_commune, :string, default: ''
    add_column :clients, :gov_interview_district, :string, default: ''
    add_column :clients, :gov_interview_city, :string, default: ''
    add_column :clients, :gov_caseworker_name, :string, default: ''
    add_column :clients, :gov_caseworker_phone, :string, default: ''

    add_column :clients, :gov_carer_name, :string, default: ''
    add_column :clients, :gov_carer_relationship, :string, default: ''
    add_column :clients, :gov_carer_home, :string, default: ''
    add_column :clients, :gov_carer_street, :string, default: ''
    add_column :clients, :gov_carer_village, :string, default: ''
    add_column :clients, :gov_carer_commune, :string, default: ''
    add_column :clients, :gov_carer_district, :string, default: ''
    add_column :clients, :gov_carer_city, :string, default: ''
    add_column :clients, :gov_carer_phone, :string, default: ''
    add_column :clients, :gov_information_source, :string, default: ''

    add_column :clients, :gov_referral_reason, :text, default: ''
    add_column :clients, :gov_guardian_comment, :text, default: ''
    add_column :clients, :gov_caseworker_comment, :text, default: ''
  end
end
