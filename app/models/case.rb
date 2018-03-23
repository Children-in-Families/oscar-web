class Case < ActiveRecord::Base
  belongs_to :family, counter_cache: true
  belongs_to :client
  belongs_to :partner, counter_cache: true
  belongs_to :province, counter_cache: true

  has_many :case_contracts
  has_many :quarterly_reports

  has_paper_trail

  scope :emergencies,    -> { where(case_type: 'EC') }
  scope :non_emergency,  -> { where.not(case_type: 'EC') }
  scope :kinships,       -> { where(case_type: 'KC') }
  scope :fosters,        -> { where(case_type: 'FC') }
  scope :most_recents,   -> { order('created_at desc') }
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
  after_create :update_client_code
  after_save :create_client_history

  def set_attributes
    if family.inactive? || family.birth_family?
      self.exited    = true
      self.exit_date = Date.today
      self.exit_note = family.family_type
    end
    self.case_type =  case family.family_type
                      when 'emergency' then 'EC'
                      when 'foster' then 'FC'
                      when 'kinship' then 'KC'
                      when 'inactive', 'birth_family' then 'Referred'
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

  def fc_or_kc?
    case_type == 'FC' || case_type == 'KC'
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
      client.status = ['EC', 'FC', 'KC'].include?(case_type) ? 'Active' : 'Referred'
    elsif exited_from_cif
      client.status = status
    elsif exited && !exited_from_cif
      if client.client_enrollments.active.empty?
        client.status = exited_was ? client.status : 'Accepted'
      else
        client.status = exited_was ? client.status : 'Active'
      end
    end
    client.save(validate: false)
  end

  def update_client_code
    client.update_attributes(code: generate_client_code) if client.code.blank? && not_ec?
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
    family.save
  end
end
