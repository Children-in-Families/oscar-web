class Organization < ActiveRecord::Base
  mount_uploader :logo, ImageUploader

  has_many :employees, class_name: 'User'

  scope :without_demo, -> { where.not(full_name: 'Demo') }
  scope :without_cwd, -> { where.not(short_name: 'cwd') }
  scope :without_shared, -> { where.not(short_name: 'shared') }
  scope :exclude_current, -> { where.not(short_name: Organization.current.short_name) }
  scope :oscar, -> { visible.where.not(short_name: 'demo') }
  scope :visible, -> { where.not(short_name: ['cwd', 'myan', 'rok', 'shared', 'my']) }
  scope :cambodian, -> { where(country: 'cambodia') }

  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }
  # validate :raise_error_non_public_tenant, on: :create

  class << self
    def current
      find_by(short_name: Apartment::Tenant.current)
    end

    def switch_to(tenant_name)
      Apartment::Tenant.switch!(tenant_name)
    end

    def create_and_build_tanent(fields = {})
      transaction do
        org = create(fields)
        Apartment::Tenant.create(fields[:short_name])

        org
      end
    end
  end

  def demo?
    short_name == 'demo'
  end

  def mho?
    short_name == 'mho'
  end

  def cif?
    short_name == 'cif'
  end

  def cwd?
    short_name == 'cwd'
  end

  def available_for_referral?
    if Rails.env.production?
      Organization.oscar.pluck(:short_name).include?(self.short_name)
    else
      Organization.visible.pluck(:short_name).include?(self.short_name)
    end
  end
end
