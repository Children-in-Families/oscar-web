class Case < ActiveRecord::Base
  belongs_to :user,   counter_cache: true
  belongs_to :family, counter_cache: true
  belongs_to :client
  belongs_to :partner, counter_cache: true
  belongs_to :province, counter_cache: true

  has_many :case_contracts
  has_many :quarterly_reports

  scope :emergencies,   -> { where(case_type: 'EC') }
  scope :non_emergency, -> { where.not(case_type: 'EC') }
  scope :kinships,      -> { where(case_type: 'KC') }
  scope :fosters,       -> { where(case_type: 'FC') }
  scope :most_recents,  -> { order('created_at desc') }
  scope :active,        -> { where(exited: false) }
  scope :inactive,      -> { where(exited: true) }

  validates :family, presence: true, :if => Proc.new { |client_case| client_case.case_type != 'EC' }

  before_save :update_client_status

  def self.latest_emergency
    emergencies.most_recents.first
  end

  def self.latest_kinship
    kinships.most_recents.first
  end

  def self.latest_foster
    fosters.most_recents.first
  end

  private

  def update_client_status
    if new_record?
      client.status = case case_type
      when 'EC' then 'Active EC'
      when 'KC' then 'Active KC'
      when 'FC' then 'Active FC'
      end
    else
      if exited
        client.status = case case_type
        when 'EC' then 'Referred'
        when 'KC', 'FC'
         if client.cases.emergencies.active.any?
           'Active EC'
         else
           'Referred'
         end
        end
      end
    end
  client.save
  end
end
