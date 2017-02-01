class GovernmentReport < ActiveRecord::Base
  belongs_to :client

  validates :client, presence: true
  validates :code, presence: true, uniqueness: true

  delegate :name, :slug, :gender, :date_of_birth, :initial_referral_date, to: :client, prefix: true

  def carer_name
    client.cases.current.try(:carer_names)
  end

  def carer_capital
    client.cases.current.try(:province).try(:name)
  end

  def carer_phone_number
    client.cases.current.try(:carer_phone_number)
  end

  def referral_name
    client.referral_source.try(:name)
  end
end
