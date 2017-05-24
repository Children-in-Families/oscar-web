class Agency < ActiveRecord::Base
  has_many :agency_clients
  has_many :clients, through: :agency_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  after_save :initial_version

  def self.name_like(values = [])
    where('name iLIKE ANY ( array[?] )', values)
  end

  def initial_version
    Version.initial(self)
  end
end
