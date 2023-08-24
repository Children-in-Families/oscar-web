class ProtectionConcern < ActiveRecord::Base
  include CacheAll

  has_many :call_protection_concerns, dependent: :restrict_with_error
  has_many :calls, through: :call_protection_concerns

  validates :content, presence: true, uniqueness: { case_sensitive: false }

  scope :dropdown_list_option, -> { pluck(:id, :content).map{|i_d, cnt| { i_d => cnt } } }
end
