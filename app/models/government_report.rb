class GovernmentReport < ActiveRecord::Base

  belongs_to :client
  has_and_belongs_to_many :quantitative_cases

  validates :code, presence: true, uniqueness: true

  after_create :set_related_client_attributes
  before_save :enable_disable_missions

  private
  def set_related_client_attributes
    self.client_code = client.code
    self.client_name = client.name
    self.client_date_of_birth = client.date_of_birth
    self.client_gender = client.gender
    if client.cases.current
      self.carer_name = client.cases.current.carer_names
      self.carer_city = client.cases.current.province.name if client.cases.current.province
      self.carer_phone_number = client.cases.current.carer_phone_number
      self.case_information_date = client.cases.current.start_date
    end
    self.save
  end

  def enable_disable_missions
    if self.mission_obtainable == false
      self.first_mission  = false
      self.second_mission = false
      self.third_mission  = false
      self.fourth_mission = false
      true
    end
  end
end