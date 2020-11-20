class ProgramStream < ActiveRecord::Base
  include UpdateFieldLabelsFormBuilder
  FORM_BUILDER_FIELDS = ['enrollment', 'exit_program'].freeze
  acts_as_paranoid without_default_scope: true, column: :archived_at

  has_many   :domain_program_streams, dependent: :destroy
  has_many   :domains, through: :domain_program_streams
  has_many   :client_enrollments, dependent: :destroy
  has_many   :clients, through: :client_enrollments
  has_many   :enrollments, dependent: :destroy
  has_many   :families, through: :enrollments, source: :programmable, source_type: 'Family'
  has_many   :trackings, dependent: :destroy
  has_many   :leave_programs, dependent: :destroy

  has_many   :program_stream_permissions, dependent: :destroy
  has_many   :users, through: :program_stream_permissions

  has_many   :program_stream_services, dependent: :destroy
  has_many   :services, through: :program_stream_services

  has_paper_trail

  accepts_nested_attributes_for :trackings, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: true

  validate  :presence_of_label
  validate  :form_builder_field_uniqueness
  validate  :rules_edition, :program_edition, on: :update, if: Proc.new { |p| p.client_enrollments.active.any? }
  validates :services, presence: true

  before_save :set_program_completed, :destroy_tracking
  after_update :auto_update_exit_program, :auto_update_enrollment, :update_save_search
  after_create :build_permission

  scope  :ordered,        ->         { order('lower(name) ASC') }
  scope  :complete,       ->         { where(completed: true) }
  scope  :ordered_by,     ->(column) { order(column) }
  scope  :filter,         ->(value)  { where(id: value) }
  scope  :name_like,      ->(value)  { where(name: value) }
  scope  :by_name,        ->(value)  { where('name iLIKE ?', "%#{value.squish}%") }
  scope  :attached_with,  -> (value) { where(entity_type: value) }

  def name=(name)
    write_attribute(:name, name.try(:strip))
  end

  def build_permission
    User.deleted_user.non_strategic_overviewers.each do |user|
      self.program_stream_permissions.find_or_create_by(user: user)
    end
  end

  def self.inactive_enrollments(obj, entity_type = nil)
    if ['Family'].include?(entity_type)
      joins(:enrollments).where("programmable_id = ? AND enrollments.created_at = (SELECT MAX(enrollments.created_at) FROM enrollments WHERE enrollments.program_stream_id = program_streams.id AND enrollments.programmable_id = #{obj.id}) AND enrollments.status = 'Exited' ", obj.id).ordered
    else
      joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{obj.id}) AND client_enrollments.status = 'Exited' ", obj.id).ordered
    end
  end

  def self.active_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Active' ", client.id).ordered
  end

  def self.without_status_by(obj, entity_type = nil)
    if ['Family'].include?(entity_type)
      ids = includes(:enrollments).where(enrollments: { programmable_id: obj.id }).order('enrollments.status ASC', :name).uniq.collect(&:id)
      where.not(id: ids).ordered
    else
      ids = includes(:client_enrollments).where(client_enrollments: { client_id: obj.id }).order('client_enrollments.status ASC', :name).uniq.collect(&:id)
      where.not(id: ids).ordered
    end
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

  def last_enrollment
    client_enrollments.last
  end

  def number_available_for_client
    quantity - client_enrollments.active.size
  end

  def enroll?(obj, entity_type = nil)
    if ['Family'].include?(entity_type)
      enrolls = enrollments.enrollments_by(obj).order(:created_at)
      (enrolls.present? && enrolls.first.status == 'Exited') || enrolls.empty?
    else
      enrollments = client_enrollments.enrollments_by(obj).order(:created_at)
      (enrollments.present? && enrollments.first.status == 'Exited') || enrollments.empty?
    end
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
    if !tracking_required && (trackings.empty? || trackings.pluck(:name).include?('') || trackings.pluck(:fields).include?([]))
      self.completed = false
      true
    else
      self.completed = true
    end
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

  private

  def presence_of_label
    validate_label(enrollment, 'enrollment') if enrollment.any?
    validate_label(exit_program, 'exit_program') if exit_program.any?
  end

  def validate_label(value, field)
    tab = field == 'exit_program' ? 5 : 3
    message = "Label " + I18n.t('cannot_be_blank')
    value.each do |v|
      unless v['label'].present?
        errors.add(field.to_sym, message)
        errors.add(:tab, tab)
        return
      end
    end
  end

  def auto_update_exit_program
    return unless exit_program_changed?
    labels_update(exit_program_change.last, exit_program_was, leave_programs)
  end

  def auto_update_enrollment
    return unless enrollment_changed?
    labels_update(enrollment_change.last, enrollment_was, client_enrollments)
  end

  def destroy_tracking
    trackings.only_deleted.delete_all!
  end

  def update_save_search
    saved_searches = AdvancedSearch.where("program_streams iLIKE ?", "%#{id}%")
    saved_searches.each do |ss|
      queries       = ss.queries
      updated_query = get_rules(queries, ss)
    end
  end

  def get_rules(queries, ss)
    queries['rules'].each do |rule|
      program_stream_old_queries = get_rules(rule, ss) if rule.has_key?('rules')
      if rule["id"].present?
        program_stream_old_queries = rule["id"]&.slice(/\__.*__/)&.gsub(/__/i,'')&.gsub(/\(|\)/i,'')&.squish
        if program_stream_old_queries.present? && (name[/#{program_stream_old_queries[0..5]}.*#{program_stream_old_queries[-4]}/i])
          query_rule = rule["id"].sub(/__.*__/, "__#{name}__")
          rule['id'] = query_rule
          ss.save
          enrollment.each do |enrolled|
            updated_enrollment = enrolled["label"]
            old_enrollment = rule["id"].gsub(/.*__/i,'')
            if updated_enrollment[/#{old_enrollment[0..5]}.*#{old_enrollment[-4]}/i]
              query_rule_enrollment = rule["id"].slice(/.*__/i) + updated_enrollment
              rule['id'] = query_rule_enrollment
              ss.save
            end
          end
        end
      end
    end
  end
end
