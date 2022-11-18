class InternalReferralProgramStream < ApplicationRecord
  belongs_to :internal_referral
  belongs_to :program_stream
end
