module AdvancedSearches
  class OverdueFormSqlBuilder
    def initialize(clients, field, operator, values)
      @clients      = clients
      @field        = field
      @operator     = operator
      @value        = values
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
        case @operator
        when 'equal'
          setting = Setting.first
          max_case_note = setting.try(:max_case_note) || 30
          case_note_frequency = setting.try(:case_note_frequency) || 'day'
          case_note_period = max_case_note.send(case_note_frequency).ago
          case_note_overdue_ids = CaseNote.no_case_note_in(case_note_period).ids

          client_ids = @clients.joins(:case_notes).where(case_notes: { id: case_note_overdue_ids }).distinct.ids
        when 'not_equal'
          setting = Setting.first
          max_case_note = setting.try(:max_case_note) || 30
          case_note_frequency = setting.try(:case_note_frequency) || 'day'
          case_note_period = max_case_note.send(case_note_frequency).ago
          case_note_overdue_ids = CaseNote.no_case_note_in(case_note_period).ids

          client_ids = @clients.joins(:case_notes).where(case_notes: { id: case_note_overdue_ids }).distinct.ids
          @clients.includes(:case_notes).where("clients.id NOT IN (?) OR case_notes.id IS NULL", client_ids).references(:case_notes).distinct.ids
        when 'is_empty'
          clients = Client.includes(:referrals).where(referrals: { date_of_referral: nil })
        when 'is_not_empty'
          clients = clients.where.not(referrals: { date_of_referral: nil })
        end

      end

  end
end
