class ProgressNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :location
  belongs_to :material
  belongs_to :progress_note_type
  belongs_to :user

  has_and_belongs_to_many :interventions
  has_and_belongs_to_many :assessment_domains

  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :all_blank

  has_paper_trail

  validates :client_id, :user_id, :date, presence: true
  validates :other_location, presence: true, if: :other_location?

  scope :other_location_like, ->(value) { where('LOWER(progress_notes.other_location) LIKE ?', "%#{value.downcase}%") }

  before_save :toggle_other_location

  def toggle_other_location
    if location.present? && !other_location?
      self.other_location = ''
    else
      self.other_location = other_location
    end
  end

  def save_attachment(params)
    files = params[:attachments][:file].first
    files.each do |file|
      attachments.create(file: file[1]) if file[1].present?
    end
  end

  def update_attachment(params)
    if params[:beforeEdit].present?
      before_edit = params[:beforeEdit].split(',')
      after_edit = params[:afterEdit].split(',')
      remove_urls = before_edit - after_edit
      remove_urls.each do |url|
        file_name = url
        attachment = attachments.find_by(file: file_name)
        attachment.destroy if attachment.present?
      end
    end
  end

  def other_location?
    other_location = Location.find_by(name: 'ផ្សេងៗ Other')
    location == other_location
  end
end
