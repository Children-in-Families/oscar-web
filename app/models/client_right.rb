class ClientRight < ActiveRecord::Base
  has_paper_trail

  has_many :client_right_government_forms, dependent: :restrict_with_error
  has_many :client_rights, through: :client_right_government_forms

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
