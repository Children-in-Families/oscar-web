module AdvancedSearches
  class OverdueFormSqlBuilder
    def initialize(clients, field, operator, values)
      @clients = clients
      @field = field
      @operator = operator
      @value = values
    end

    def get_sql
      sql_string = 'clients.id IN (?)'

      case @field
      when 'no_case_note'
        values = no_case_note
      when 'has_overdue_task'
        values = has_overdue_task
      when 'has_overdue_forms'
        values = has_overdue_forms
      when 'has_overdue_assessment'
        values = has_overdue_assessment
      end
      { id: sql_string, values: values }
    end

    private

    def no_case_note
      client_ids = []
      setting = Setting.first
      max_case_note = setting.max_case_note || 30
      case_note_frequency = setting.case_note_frequency || 'day'
      case_note_period = max_case_note.send(case_note_frequency).ago
      case_note_overdue_ids = CaseNote.no_case_note_in(case_note_period).ids

      client_ids = @clients.joins(:case_notes).where(case_notes: { id: case_note_overdue_ids }).distinct.ids
      return client_ids if @value == 'true'
      client_ids = Client.includes(:case_notes).where('clients.id NOT IN (?) OR case_notes.id IS NULL', client_ids).references(:case_notes).distinct.ids
    end

    def has_overdue_task
      client_ids = []
      task_client_ids = Task.overdue_incomplete.pluck(:client_id)
      client_ids = @clients.where(id: task_client_ids).ids
      return client_ids if @value == 'true'
      client_ids = @clients.where(id: task_client_ids).ids
      client_ids = Client.where.not(id: client_ids).ids
    end

    def has_overdue_forms
      client_ids = []
      clients = Client.joins(:custom_fields).where.not(custom_fields: { frequency: '' }) + Client.joins(:client_enrollments).where(client_enrollments: { status: 'Active' })
      clients.uniq.each do |client|
        custom_fields = client.custom_fields.where.not(frequency: '')
        custom_fields.each do |custom_field|
          client_ids << client.id if client.next_custom_field_date(client, custom_field) < Date.today
        end
        client_active_enrollments = client.client_enrollments.active
        client_active_enrollments.each do |client_active_enrollment|
          next unless client_active_enrollment.program_stream.tracking_required?
          trackings = client_active_enrollment.trackings.where.not(frequency: '')
          trackings.each do |tracking|
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            client_ids << client.id if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
          end
        end
      end

      client_ids = @clients.where(id: client_ids.compact.uniq).ids
      return client_ids if @value == 'true'
      client_ids = Client.where.not(id: client_ids.compact.uniq).ids
    end

    def has_overdue_assessment
      ids = []
      setting = Setting.first
      Client.joins(:assessments).active_accepted_status.each do |client|
        next if !client.eligible_default_csi? && !(client.assessments.customs.any?)
        custom_assessment_setting_ids = client.assessments.customs.map { |ca| ca.domains.pluck(:custom_assessment_setting_id) }.flatten.uniq
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          if client.next_assessment_date < Date.today
            ids << client.id
          else
            CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
              ids << client.id if client.custom_next_assessment_date(nil, custom_assessment_setting.id) < Date.today
            end
          end
        elsif setting.enable_default_assessment?
          ids << client.id if client.next_assessment_date < Date.today
        elsif setting.enable_custom_assessment?
          CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            ids << client.id if client.custom_next_assessment_date(nil, custom_assessment_setting.id) < Date.today
          end
        end
      end
      ids = @clients.where(id: ids.compact.uniq).ids
      return ids if @value == 'true'
      ids = Client.where.not(id: ids).ids
    end
  end
end
