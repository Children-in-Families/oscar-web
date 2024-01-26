class QuantitativeType < ActiveRecord::Base
  extend Enumerize

  VISIBLE_ON = %w(client family community).freeze
  serialize :visible_on, Array

  enumerize :field_type, in: %w(select_option free_text), default: :select_option, predicates: true, scope: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :field_type, presence: true
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
      includes(:quantitative_cases).where('quantitative_types.visible_on ILIKE ?', "%#{visible_on}%").to_a
    end
  end

  def self.cach_free_text_fields_by_visible_on(visible_on)
    Rails.cache.fetch([Apartment::Tenant.current, "FreeTextQuantitativeType", visible_on]) do
      QuantitativeType.with_field_type(:free_text).where('visible_on ILIKE ?', "%#{visible_on}%").to_a
    end
  end

  def self.cach_by_quantitative_type_ids(quantitative_type_ids)
    Rails.cache.fetch([Apartment::Tenant.current, "quantitative_type_ids", quantitative_type_ids]) do
      includes(:quantitative_cases).where(id: quantitative_type_ids).to_a
    end
  end

  def self.cached_quantitative_cases
    Rails.cache.fetch([Apartment::Tenant.current, 'QuantitativeType', 'cached_quantitative_cases']) {
      joins(:quantitative_cases).distinct.to_a
    }
  end

  def self.cach_by_quantitative_type_ids(quantitative_type_ids)
    Rails.cache.fetch([Apartment::Tenant.current, "quantitative_type_ids", quantitative_type_ids]) do
      QuantitativeType.includes(:quantitative_cases).where(id: quantitative_type_ids).to_a
    end
  end

  def self.cached_quantitative_cases
    Rails.cache.fetch([Apartment::Tenant.current, 'QuantitativeType', 'cached_quantitative_cases']) {
      joins(:quantitative_cases).distinct.to_a
    }
  end

  def visible_for_client?
    visible_on.include?('client')
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

    Rails.cache.delete([Apartment::Tenant.current, "FreeTextQuantitativeType", "client"] )
    Rails.cache.delete([Apartment::Tenant.current, "FreeTextQuantitativeType", "community"] )
    Rails.cache.delete([Apartment::Tenant.current, "FreeTextQuantitativeType", "family"] )

    Rails.cache.delete([Apartment::Tenant.current, 'QuantitativeType', 'cached_quantitative_cases'] )
  end
end
