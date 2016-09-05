class Case < ActiveRecord::Base
  belongs_to :user,   counter_cache: true
  belongs_to :family, counter_cache: true
  belongs_to :client
  belongs_to :partner, counter_cache: true
  belongs_to :province, counter_cache: true

  has_many :case_contracts
  has_many :quarterly_reports

  scope :emergencies,    -> { where(case_type: 'EC') }
  scope :non_emergency,  -> { where.not(case_type: 'EC') }
  scope :kinships,       -> { where(case_type: 'KC') }
  scope :fosters,        -> { where(case_type: 'FC') }
  scope :most_recents,   -> { order('created_at desc') }
  scope :active,         -> { where(exited: false) }
  scope :inactive,       -> { where(exited: true) }
  scope :with_reports,   -> { joins(:quarterly_reports).uniq }
  scope :with_contracts, -> { joins(:case_contracts).uniq }
  scope :case_types,     -> { pluck(:case_type).uniq }

  validates :family, presence: true, if: proc { |client_case| client_case.case_type != 'EC' }
  validates :case_type, presence: true
  validates :exit_date, presence: true, if: proc { |client_case| client_case.exited? }
  validates :exit_note, presence: true, if: proc { |client_case| client_case.exited? }

  before_save :update_client_status
  after_save :update_cases_to_exited_from_cif
  after_create :update_client_code

  def self.latest_emergency
    emergencies.most_recents.first
  end

  def self.latest_kinship
    kinships.most_recents.first
  end

  def self.latest_foster
    fosters.most_recents.first
  end

  def self.current
    active.most_recents.first
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

  def most_current?
    client.status == "Active #{case_type}"
  end

  private

  def update_client_status
    if new_record?
      client.status =
        case case_type
        when 'EC' then 'Active EC'
        when 'KC' then 'Active KC'
        when 'FC' then 'Active FC'
        end
    elsif exited_from_cif
      client.status = status
    elsif exited && !exited_from_cif
      client.status =
        case case_type
        when 'EC' then 'Referred'
        when 'KC', 'FC'
          client.cases.emergencies.active.any? ? 'Active EC' : 'Referred'
        end
    end

    client.save
  end

  def update_client_code
    client.update_attributes(code: generate_client_code) if client.code.blank? && not_ec?
  end

  def generate_client_code
    return [2000, Client.start_with_code(2).maximum(:code).to_i + 1].max if kc?
    return [1000, Client.start_with_code(1).maximum(:code).to_i + 1].max if fc?
  end

  def update_cases_to_exited_from_cif
    if exited_from_cif
      client.cases.active.update_all(
        exited_from_cif: true,
        exited: true,
        exit_date: exit_date,
        exit_note: exit_note
      )
    end
  end
end
