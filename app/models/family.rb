class Family < ActiveRecord::Base
  include EntityTypeCustomField
  include Brc::Family

  TYPES = ['Birth Family (Both Parents)', 'Birth Family (Only Mother)',
    'Birth Family (Only Father)', 'Extended Family / Kinship Care',
    'Short Term / Emergency Foster Care', 'Long Term Foster Care',
    'Domestically Adopted', 'Child-Headed Household', 'No Family', 'Other']
  STATUSES = ['Active', 'Inactive']

  acts_as_paranoid

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true

  belongs_to :province, counter_cache: true
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  belongs_to :user

  has_many :cases, dependent: :destroy
  has_many :clients, through: :cases
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :family_members, dependent: :destroy
  has_many :family_referrals, dependent: :destroy

  accepts_nested_attributes_for :family_members, reject_if: :all_blank, allow_destroy: true

  has_paper_trail

  before_validation :assign_family_type, if: [:new_record?, :brc?]

  validates :family_type, presence: true, inclusion: { in: TYPES }
  validates :code, uniqueness: { case_sensitive: false }, if: 'code.present?'
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :client_must_only_belong_to_a_family

  after_create :assign_slug
  after_save :save_family_in_client, :mark_referral_as_saved

  scope :address_like,               ->(value) { where('address iLIKE ?', "%#{value.squish}%") }
  scope :caregiver_information_like, ->(value) { where('caregiver_information iLIKE ?', "%#{value.squish}%") }
  scope :case_history_like,          ->(value) { where('case_history iLIKE ?', "%#{value.squish}%") }
  scope :family_id_like,             ->(value) { where('code iLIKE ?', "%#{value.squish}%") }
  scope :street_like,                ->(value) { where('street iLIKE ?', "%#{value.squish}%") }
  scope :house_like,                 ->(value) { where('house iLIKE ?', "%#{value.squish}%") }
  scope :emergency,                  ->        { where(family_type: 'Short Term / Emergency Foster Care') }
  scope :foster,                     ->        { where(family_type: 'Long Term Foster Care') }
  scope :kinship,                    ->        { where(family_type: 'Extended Family / Kinship Care') }
  scope :birth_family_both_parents,  ->        { where(family_type: 'Birth Family (Both Parents)') }
  scope :birth_family_only_father,   ->        { where(family_type: 'Birth Family (Only Father)') }
  scope :birth_family_only_mother,   ->        { where(family_type: 'Birth Family (Only Mother)') }
  scope :domestically_adopted,       ->        { where(family_type: 'Domestically Adopted') }
  scope :child_headed_household,     ->        { where(family_type: 'Child-Headed Household') }
  scope :no_family,                  ->        { where(family_type: 'No Family') }
  scope :other,                      ->        { where(family_type: 'Other') }
  scope :active,                     ->        { where(status: 'Active') }
  scope :inactive,                   ->        { where(status: 'Inactive') }
  scope :name_like,                  ->(value) { where('name iLIKE ?', "%#{value.squish}%") }
  scope :province_are,               ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :as_non_cases,               ->        { where.not(family_type: ['Short Term / Emergency Foster Care', 'Long Term Foster Care', 'Extended Family / Kinship Care']) }
  scope :by_status,                  ->(value) { where(status: value) }
  scope :by_family_type,             ->(value) { where(family_type: value) }

  def self.update_brc_aggregation_data
    Organization.switch_to 'brc'
    Family.find_each(&:save_aggregation_data)
  end

  def member_count
    brc? ? family_members.count : (male_adult_count.to_i + female_adult_count.to_i + male_children_count.to_i + female_children_count.to_i)
  end

  def emergency?
    family_type == 'Short Term / Emergency Foster Care'
  end

  def foster?
    family_type == 'Long Term Foster Care'
  end

  def kinship?
    family_type == 'Extended Family / Kinship Care'
  end

  def birth_family_both_parents?
    family_type == 'Birth Family (Both Parents)'
  end

  def inactive?
    status == 'Inactive'
  end

  def is_case?
    emergency? || foster? || kinship?
  end

  def name=(name)
    write_attribute(:name, name.try(:strip))
  end

  def self.mapping_family_type_translation
    [I18n.backend.send(:translations)[:en][:default_family_fields][:family_type_list].values, I18n.t('default_family_fields.family_type_list').values].transpose
  end

  def current_clients
    Client.where(current_family_id: self.id)
  end

  def destroy
    if !deleted?
      with_transaction_returning_status do
        run_callbacks :destroy do
          if persisted?
            # Handle composite keys, otherwise we would just use
            # `self.class.primary_key.to_sym => self.id`.
            self.class
              .delete_all(Hash[[Array(self.class.primary_key), Array(id)].transpose])
          end

          @_trigger_destroy_callback = true

          stale_paranoid_value
          self
        end
      end
    else
      destroy_fully! if paranoid_configuration[:double_tap_destroys_fully]
    end
  end

  private

  def assign_family_type
    self.family_type = 'Other'
  end

  def brc?
    Organization.brc?
  end

  def client_must_only_belong_to_a_family
    clients = Client.where.not(current_family_id: nil).where.not(current_family_id: self.id).ids
    existed_clients = children & clients
    existed_clients = Client.where(id: existed_clients).map(&:en_and_local_name) if existed_clients.present?
    error_message = "#{existed_clients.join(', ')} #{'has'.pluralize(existed_clients.count)} already existed in other family"
    errors.add(:children, error_message) if existed_clients.present?
  end

  def save_family_in_client
    Client.where(current_family_id: self.id).where.not(id: self.children).update_all(current_family_id: nil)
    self.children.each do |child|
      client = Client.find_by(id: child)
      next if client.nil?
      client.families << self
      client.current_family_id = self.id
      client.families.uniq
      client.save(validate: false)
    end
  end

  def stale_paranoid_value
    self.paranoid_value = self.class.delete_now_value
    clear_attribute_changes([self.class.paranoid_column])
  end

  def assign_slug
    return if self.slug.present?
    self.slug = "#{Organization.current.short_name}-#{self.id}"
    self.save(validate: false)
  end

  def mark_referral_as_saved
    if self.slug.split('-').first != Organization.current.short_name
      referral = FamilyReferral.find_by(slug: self.slug)
      return if referral.nil?
      referral.saved = true
      referral.save(validate: false)
    end
  end
end
