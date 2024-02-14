class ReferralSerializer < ActiveModel::Serializer
  attributes :id, :slug, :date_of_referral, :referred_to, :referred_from, :referral_reason,
             :name_of_referee, :referral_phone, :referee_id, :client_name, :consent_form, :saved, :client_id,
             :ngo_name, :client_global_id, :external_id, :external_id_display,
             :mosvy_number, :external_case_worker_name, :external_case_worker_id, :client_gender,
             :client_date_of_birth, :village_code, :referee_email, :level_of_risk, :referral_status, :deleted_at
end
