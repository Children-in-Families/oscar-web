class AbleScreeningQuestion < ActiveRecord::Base

  MODES  = %w(yes_no free_text).freeze

  belongs_to :stage
  belongs_to :question_group
  has_many :answers, dependent: :destroy
  has_many :clients, through: :answers
  has_many :attachments

  has_paper_trail

  accepts_nested_attributes_for :attachments

  scope :non_stage, -> { where(stage: nil) }
  scope :with_stage, -> { joins(:stage).order('from_age') }

  validates :question, :mode, presence: true
  validates :mode, inclusion: { in: MODES }

  validates :question_group, presence: true, if: proc { |object| object.stage.present? }

  delegate :from_age_as_date, :to_age_as_date, :non_stage, to: :stage, allow_nil: true

  before_save :check_mode

  def check_mode
    self.alert_manager = false if self.free_text?
    true
  end

  def has_image?
    attachments.any?
  end

  def first_image
    attachments.first.image if attachments.any?
  end

  def has_stage?
    stage.present?
  end

  def has_group?
    group.present?
  end

  def free_text?
    mode == MODES[1]
  end

  def yes_no?
    mode == MODES[0]
  end

  def self.has_alert_manager?(client)
    where(alert_manager: true).joins(:clients)
                                .where('clients.id = ?', client.id).any?
  end
end
