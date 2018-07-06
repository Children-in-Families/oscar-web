# Client asked to hide it for now
class GovernmentForm < ActiveRecord::Base
  has_paper_trail

  belongs_to :client

  has_many :government_form_interviewees, dependent: :destroy
  has_many :interviewees, through: :government_form_interviewees

  # validates :client, presence: true

#   delegate :name, :slug, :gender, :date_of_birth, :initial_referral_date, to: :client, prefix: true

#   def carer_name
#     client.cases.current.try(:carer_names)
#   end

#   def carer_capital
#     client.cases.current.try(:province).try(:name)
#   end

#   def carer_phone_number
#     client.cases.current.try(:carer_phone_number)
#   end

#   def referral_name
#     client.referral_source.try(:name)
#   end
  def self.filter(options)
    records = all
    records.where(name: options[:name]) if options[:name].present?
  end
end
