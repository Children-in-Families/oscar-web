class ProtectionConcern < ActiveRecord::Base
  has_many :client_protection_concerns, dependent: :restrict_with_error
  has_many :clients, through: :client_protection_concerns

  validates :content, presence: true, uniqueness: { case_sensitive: false }

  scope :dropdown_list_option, -> { pluck(:id, :content).map{|i_d, cnt| { i_d => cnt } } }

end
