class ReferralSource < ActiveRecord::Base
  has_ancestry
  has_many :clients, dependent: :restrict_with_error
  has_paper_trail
  REFERRAL_SOURCES = ['ក្រសួង សអយ/មន្ទីរ សអយ', 'អង្គការមិនមែនរដ្ឋាភិបាល', 'មន្ទីរពេទ្យ', 'នគរបាល', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌', 'រកឃើញនៅតាមទីសាធារណៈ', 'ស្ថាប័នរដ្ឋ', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន', 'ទូរស័ព្ទទាន់ហេតុការណ៍', 'មកដោយខ្លួនឯង', 'គ្រួសារ', 'មិត្តភក្ដិ', 'អាជ្ញាធរដែនដី', 'ផ្សេងៗ', 'សហគមន៍', 'ព្រះវិហារ', 'MoSVY External System'].freeze
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :restrict_update, on: :update
  before_destroy :restrict_delete
  after_save :update_client_referral_source
  after_commit :flush_cache

  scope :parent_categories,       ->        { where(name: REFERRAL_SOURCES) }
  scope :child_referrals,          ->        { where.not(name: REFERRAL_SOURCES) }

  def self.cache_referral_source_options
    Rails.cache.fetch([Apartment::Tenant.current, 'ReferralSource', 'referral_source_options']) do
      ReferralSource.child_referrals.order(:name).map { |s| { s.id.to_s => s.name } }
    end
  end

  def self.cache_local_referral_source_category_options
    Rails.cache.fetch([Apartment::Tenant.current, 'ReferralSource', 'cache_local_referral_source_category_options']) do
      ReferralSource.child_referrals.order(:name).map { |s| { s.id.to_s => s.name } }
    end
  end

  def self.cache_referral_source_category_options
    Rails.cache.fetch([Apartment::Tenant.current, 'ReferralSource', 'cache_referral_source_category_options']) do
      ReferralSource.child_referrals.order(:name).map { |s| { s.id.to_s => s.name } }
    end
  end

  private

  def update_client_referral_source
    clients = Client.where(referral_source_id: self.id)
    clients.each do |client|
      client.referral_source_category_id = self.try(:ancestry)
      client.save(validate: false)
    end
  end

  def restrict_update
    errors.add(:base, 'Referral Source cannot be updated') if REFERRAL_SOURCES.include?(name_was)
  end

  def restrict_delete
    errors.add(:base, 'Referral Source cannot be deleted') if REFERRAL_SOURCES.include?(self.name)
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'ReferralSource', 'referral_source_options'])
    Rails.cache.delete([Apartment::Tenant.current, 'ReferralSource', 'cache_referral_source_category_options'])
    Rails.cache.delete([Apartment::Tenant.current, 'ReferralSource', 'cache_local_referral_source_category_options'])
  end
end
