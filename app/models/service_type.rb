class ServiceType < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_service_types, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_service_types

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
