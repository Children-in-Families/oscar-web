class ProgramStream < ActiveRecord::Base
  FORM_BUILDER_FIELDS = ['enrollment', 'exit_program'].freeze

  has_many   :domain_program_streams, dependent: :destroy
  has_many   :domains, through: :domain_program_streams
  has_many   :client_enrollments, dependent: :destroy
  has_many   :clients, through: :client_enrollments
  has_many   :trackings, dependent: :destroy
  has_many   :leave_programs, dependent: :destroy

  has_many   :program_stream_permissions, dependent: :destroy
  has_many   :users, through: :program_stream_permissions

  has_paper_trail

  accepts_nested_attributes_for :trackings, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: true
  validate  :form_builder_field_uniqueness
  validate  :rules_edition, :program_edition, on: :update, if: Proc.new { |p| p.client_enrollments.active.any? }

  # validate  :validate_remove_enrollment_field, :validate_remove_exit_program_field, if: -> { id.present? }
  after_save :set_program_completed
  after_update :auto_update_exit_program, :auto_update_enrollment
  after_create :build_permission

  scope  :ordered,        ->         { order('lower(name) ASC') }
  scope  :complete,       ->         { where(completed: true) }
  scope  :ordered_by,     ->(column) { order(column) }
  scope  :filter,         ->(value)  { where(id: value) }
  scope  :name_like,      ->(value)  { where(name: value) }
  scope  :by_name,        ->(value)  { where('name iLIKE ?', "%#{value}%") }

  def build_permission
    User.all.each do |user|
      next if user.admin? || user.strategic_overviewer?
      self.program_stream_permissions.find_or_create_by(user: user)
    end
  end

  def self.inactive_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Exited' ", client.id).ordered
  end

  def self.active_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Active' ", client.id).ordered
  end

  def self.without_status_by(client)
    ids = includes(:client_enrollments).where(client_enrollments: { client_id: client.id }).order('client_enrollments.status ASC', :name).uniq.collect(&:id)
    where.not(id: ids).ordered
  end

  def form_builder_field_uniqueness
    errors_massage = []
    FORM_BUILDER_FIELDS.each do |field|
      labels = []
      next unless send(field.to_sym).present?
      send(field.to_sym).map{ |obj| labels << obj['label'] if obj['label'] != 'Separation Line' && obj['type'] != 'paragraph' }
      errors_massage << (errors.add field.to_sym, "Fields duplicated!") unless (labels.uniq.length == labels.length)
    end
    errors_massage
  end

  def auto_update_exit_program
    return unless exit_program_changed?
    labels_changed = []
    exit_programs_changed =  exit_program_change.last - exit_program_was
    exit_programs_changed.each do |exit_program_changed|
      exit_program_was.each do |program|
        labels_changed << [program['label'], exit_program_changed['label']] if program['name'] == exit_program_changed['name']
      end
    end
    leave_programs.each do |leave_program|
      labels_changed.each do |label_old, label_new|
        leave_program.properties[label_new] = leave_program.properties.delete label_old
      end
      leave_program.save
    end
  end

  def auto_update_enrollment
    return unless enrollment_changed?
    labels_changed = []
    enrollments_changed =  enrollment_change.last - enrollment_was
    enrollments_changed.each do |enrollment_changed|
      enrollment_was.each do |program|
        labels_changed << [program['label'], enrollment_changed['label']] if program['name'] == enrollment_changed['name']
      end
    end
    client_enrollments.each do |client_enrollment|
      labels_changed.each do |label_old, label_new|
        client_enrollment.properties[label_new] = client_enrollment.properties.delete label_old
      end
      client_enrollment.save
    end
  end

  def rules_edition
    if rules_changed?
      current_client_ids  = get_client_ids(rules).to_set
      previous_client_ids = get_client_ids(rules_was).to_set

      unless unchanged_rules?(current_client_ids, previous_client_ids)
        error_message = "#{I18n.t('rules_has_been_modified')}"
        self.rules = rules_was
        errors.add(:rules, error_message)
      end
    end
  end

  def program_edition
    clients.each do |client|
      program_stream_ids = client.client_enrollments.active.pluck(:program_stream_id).to_set
      can_edit_program = false
      if program_exclusive_changed? && program_exclusive.any? && program_exclusive.to_set.subset?(program_stream_ids)
        self.program_exclusive = program_exclusive_was
        error_message = "#{I18n.t('program_exclusive_has_been_modified')}"
        errors.add(:program_exclusive, error_message)
        can_edit_program = true
      end

      if mutual_dependence_changed? && mutual_dependence.any? && !(mutual_dependence.to_set.subset?(program_stream_ids))
        self.mutual_dependence = mutual_dependence_was
        error_message = "#{I18n.t('mutual_dependence_has_been_modified')}"
        errors.add(:mutual_dependence, error_message)
        can_edit_program = true
      end

      break if can_edit_program
    end
  end

  # def validate_remove_enrollment_field
  #   return unless enrollment_changed?
  #   error_fields = []
  #   properties = client_enrollments.pluck(:properties).select(&:present?)
  #   properties.each do |property|
  #     field_remove = enrollment_change.first - enrollment_change.last
  #     field_remove.each do |field|
  #       label_name = property[field['label']]
  #       error_fields << field['label'] if label_name.present?
  #     end
  #   end
  #   return unless error_fields.present?
  #   error_message = "#{error_fields.uniq.join(', ')} #{I18n.t('cannot_remove_or_update')}"
  #   errors.add(:enrollment, "#{error_message}")
  #   errors.add(:tab, '3')
  # end

  # def validate_remove_exit_program_field
  #   return unless exit_program_changed?
  #   error_fields = []
  #   properties = leave_programs.pluck(:properties).select(&:present?)
  #   properties.each do |property|
  #     field_remove = exit_program_change.first - exit_program_change.last
  #     field_remove.each do |field|
  #       label_name = property[field['label']]
  #       error_fields << field['label'] if label_name.present?
  #     end
  #   end
  #   return unless error_fields.present?
  #   error_message = "#{error_fields.uniq.join(', ')} #{I18n.t('cannot_remove_or_update')}"
  #   errors.add(:exit_program, "#{error_message}")
  #   errors.add(:tab, '5')
  # end

  def last_enrollment
    client_enrollments.last
  end

  def number_available_for_client
    quantity - client_enrollments.active.size
  end

  def enroll?(client)
    enrollments = client_enrollments.enrollments_by(client).order(:created_at)
    (enrollments.present? && enrollments.first.status == 'Exited') || enrollments.empty?
  end

  def is_used?
    client_enrollments.active.present?
  end

  def has_program_exclusive?
    program_exclusive.any?
  end

  def has_mutual_dependence?
    mutual_dependence.any?
  end

  def has_rule?
    rules.present?
  end

  private

  def get_client_ids(rules)
    active_client_ids = client_enrollments.active.pluck(:client_id).uniq
    active_clients    = Client.where(id: active_client_ids)
    clients           = AdvancedSearches::ClientAdvancedSearch.new(rules, active_clients)
    clients.filter.ids
  end

  def unchanged_rules?(current_ids, previous_ids)
    if current_ids.any? && previous_ids.any?
      previous_ids.subset?(current_ids)
    else
      return false
    end
  end

  def set_program_completed
    return update_columns(completed: false) if (enrollment.empty? || exit_program.empty? || trackings.empty? || trackings.pluck(:name).include?('') || trackings.pluck(:fields).include?([])) && !tracking_required
    update_columns(completed: true)
  end

  def enrollment_errors_message
    properties = client_enrollments.pluck(:properties).select(&:present?)
    error_fields(properties, enrollment_change).join(', ')
  end

  def tracking_errors_message
    properties = trackings.pluck(:properties).select(&:present?)
    error_fields(properties, tracking_change).join(', ')
  end

  def exit_program_errors_message
    properties = leave_programs.pluck(:properties).select(&:present?)
    error_fields(properties, exit_program_change).join(', ')
  end

  def error_fields(properties, column_change)
    error_fields = []
    properties.each do |property|
      field_remove = column_change.first - column_change.last
      field_remove.map{ |f| error_fields << f['label'] if property[f['label']].present? }
    end
    error_fields.uniq
  end
end
