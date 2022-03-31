class QuantitativeType < ActiveRecord::Base
  VISIBLE_ON = %w(client family community).freeze
  serialize :visible_on, Array

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate  :validate_visible_on
  validates :visible_on, presence: true

  has_many :quantitative_cases
  has_many :quantitative_type_permissions, dependent: :destroy
  has_many :users, through: :quantitative_type_permissions

  has_paper_trail

  default_scope { order(name: :asc) }

  accepts_nested_attributes_for :quantitative_cases, reject_if: :all_blank, allow_destroy: true

  scope :name_like, ->(name) { where('quantitative_types.name iLIKE ?', "%#{name}%") }

  after_create :build_permission
  after_commit :flush_cach

  def self.cach_by_visible_on(visible_on)
    Rails.cache.fetch([Apartment::Tenant.current, "QuantitativeType", visible_on]) do
      QuantitativeType.includes(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', "%#{visible_on}%")
    end
  end

  def self.cach_by_quantitative_type_ids(quantitative_type_ids)
    Rails.cache.fetch([Apartment::Tenant.current, "quantitative_type_ids", quantitative_type_ids]) do
      QuantitativeType.includes(:quantitative_cases).where(id: quantitative_type_ids)
    end
  end

  private

  def validate_visible_on
    if visible_on.count > VISIBLE_ON.count || visible_on.any?{ |visible| VISIBLE_ON.exclude?(visible) }
      errors.add(:visible_on, :invalid)
    end
  end

  def build_permission
    User.non_strategic_overviewers.each do |user|
      self.quantitative_type_permissions.find_or_create_by(user_id: user.id)
    end
  end

  def flush_cach
    Rails.cache.delete([Apartment::Tenant.current, "QuantitativeType", "client"] )
    Rails.cache.delete([Apartment::Tenant.current, "QuantitativeType", "community"] )
    Rails.cache.delete([Apartment::Tenant.current, "QuantitativeType", "family"] )
  end
end
