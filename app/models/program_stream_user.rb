class ProgramStreamUser < ActiveRecord::Base
  belongs_to :program_stream
  belongs_to :internal_referral_users, class_name: "User", foreign_key: "user_id"
end
