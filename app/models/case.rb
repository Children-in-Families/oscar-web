class Case < ActiveRecord::Base
  belongs_to :family, counter_cache: true
  belongs_to :client
  belongs_to :partner, counter_cache: true
  belongs_to :province, counter_cache: true

  has_many :case_contracts, dependent: :destroy
  has_many :quarterly_reports, dependent: :destroy

  acts_as_paranoid
  has_paper_trail

  scope :emergencies,    -> { where(case_type: 'EC') }
  scope :non_emergency,  -> { where.not(case_type: 'EC') }
  scope :kinships,       -> { where(case_type: 'KC') }
  scope :fosters,        -> { where(case_type: 'FC') }
  scope :most_recents,   -> { order('id, created_at desc') }
  scope :last_exited,    -> { order('exit_date desc').first }
  scope :active,         -> { where(exited: false) }
  scope :inactive,       -> { where(exited: true) }
  scope :with_reports,   -> { joins(:quarterly_reports).uniq }
  scope :with_contracts, -> { joins(:case_contracts).uniq }
  scope :case_types,     -> { exclude_referred.pluck(:case_type).uniq }
  scope :currents,       -> { active.where(current: true) }
  scope :exclude_referred, -> { where.not(case_type: 'Referred') }

  validates :family, presence: true, if: proc { |client_case| client_case.case_type != 'EC' }
  validates :case_type, :start_date,  presence: true
  validates :exit_date, :exit_note, presence: true, if: proc { |client_case| client_case.exited? }

  before_validation :set_attributes, if: -> { new_record? && start_date.nil? }
  before_save :update_client_status, :set_current_status
  before_create :add_family_children
  after_save :create_client_history

  def set_attributes
    if ['Birth Family (Both Parents)', 'Birth Family (Only Mother)',
      'Birth Family (Only Father)', 'Domestically Adopted',
      'Child-Headed Household', 'No Family', 'Other'].include?(family.family_type)
      self.exit_date = Date.today
      self.exit_note = family.family_type
    end
    self.case_type =  case family.family_type
                      when 'Short Term / Emergency Foster Care' then 'EC'
                      when 'Long Term Foster Care' then 'FC'
                      when 'Extended Family / Kinship Care' then 'KC'
                      when 'Birth Family (Both Parents)',
                        'Birth Family (Only Mother)',
                        'Birth Family (Only Father)',
                        'Domestically Adopted',
                        'Child-Headed Household',
                        'No Family', 'Other' then 'Referred'
                      end
    self.start_date = Date.today
  end

  def short_start_date
    start_date.end_of_month.strftime '%b-%y'
  end

  def self.latest_emergency
    emergencies.most_recents.first
  end

  def self.latest_kinship
    kinships.most_recents.first
  end

  def self.latest_foster
    fosters.most_recents.first
  end

  def self.cases_by_clients(clients)
    currents.where(client_id: clients.ids)
  end

  def self.current
    active.most_recents.first
  end

  def current?
    client.cases.exclude_referred.current == self
  end

  def kc?
    case_type == 'KC'
  end

  def fc?
    case_type == 'FC'
  end

  def not_ec?
    case_type != 'EC'
  end

  def ec?
    case_type == 'EC'
  end

  private

  def set_current_status
    c = Client.find(client.id)
    if new_record? && c.cases.exclude_referred.active.size > 1
      c.cases.exclude_referred.update_all(current: false)
      c.cases.exclude_referred.last.update_attributes(current: true)
    elsif c.cases.exclude_referred.active.size == 1 && c.cases.exclude_referred.active.first.ec? && !c.cases.exclude_referred.active.first.current?
      c.cases.exclude_referred.first.update_attributes(current: true)
    end
  end

  def update_client_status
    if new_record?
      client.status = client.status
    end
    client.save(validate: false)
  end

  def generate_client_code
    return [2000, Client.start_with_code(2).maximum(:code).to_i + 1].max if kc?
    return [1000, Client.start_with_code(1).maximum(:code).to_i + 1].max if fc?
  end

  def create_client_history
    ClientHistory.initial(client)
  end

  def add_family_children
    return if family.children.include?(client.id)
    family.children << client.id
    family.save(validate: false)
  end
end
