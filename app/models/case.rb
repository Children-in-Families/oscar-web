class Case < ActiveRecord::Base

  belongs_to :user,   counter_cache: true
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
  scope :active,         -> { where(exited: false) }
  scope :inactive,       -> { where(exited: true) }
  scope :with_reports,   -> { joins(:quarterly_reports).uniq }
  scope :with_contracts, -> { joins(:case_contracts).uniq }
  scope :case_types,     -> { pluck(:case_type).uniq }
  scope :currents,       -> { active.where(current: true) }

  validates :family, presence: true, if: proc { |client_case| client_case.case_type != 'EC' }
  validates :case_type, :start_date,  presence: true
  validates :exit_date, :exit_note, presence: true, if: proc { |client_case| client_case.exited? }

  before_save :update_client_status, :set_current_status
  after_save :update_cases_to_exited_from_cif, :create_client_history
  after_create :update_client_code

  before_validation :set_attributes, if: -> { new_record? && start_date.nil? }

  def set_attributes
    self.case_type =  case family.family_type
                        when 'emergency' then 'EC'
                        when 'foster'    then 'FC'
                        when 'kinship'   then 'KC'
                        else 'EC'
                        end
    self.start_date = Date.today
    self.user_id    = client.user_id
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
    client.cases.current == self
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
    if new_record? && c.cases.active.size > 1
      c.cases.update_all(current: false)
      c.cases.last.update_attributes(current: true)
    elsif c.cases.active.size == 1 && c.cases.active.first.ec? && !c.cases.active.first.current?
      c.cases.first.update_attributes(current: true)
    end
  end

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
    if exited_from_cif && status_was.empty? && User.managers.any?
      if client.cases.active.update_all(exited_from_cif: true, exited: true, exit_date: exit_date, exit_note: exit_note)
        ClientMailer.exited_notification(client, User.managers.pluck(:email)).deliver_now
      end
    end
  end

  def create_client_history
    ClientHistory.initial(client)
  end
end
