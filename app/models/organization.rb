class Organization < ActiveRecord::Base
  mount_uploader :logo, ImageUploader

  has_many :employees, class_name: 'User'

  scope :without_demo, -> { where.not(full_name: 'Demo') }

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

  def without_demo_and_mho
    %w(demo mho).exclude?(short_name)
  end
end
