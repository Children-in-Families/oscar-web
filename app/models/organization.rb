class Organization < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  has_many :employees, class_name: 'User'

  validates :full_name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }
  validate :raise_error_non_public_tenant, on: :create

  private
    def raise_error_non_public_tenant
      if Apartment::Tenant.current != 'public'
        self.errors[:non_public_tenant] << 'could not create organization on non public tenant'
      end
    end

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
end
