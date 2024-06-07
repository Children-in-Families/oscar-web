class InternalReferralSerializer < ActiveModel::Serializer
  attributes :id, :referral_date, :client_id, :user_id, :client_representing_problem,
             :emergency_note, :referral_reason, :crisis_management, :referral_decision,
             :attachments, :program_stream_ids
end
