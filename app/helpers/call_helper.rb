module CallHelper
  def call_report_builder_fields
    args = group_call_field_types
    call_builder_fields = AdvancedSearches::AdvancedSearchFields.new('hotline', args).render
  end

  def group_call_field_types
    translations = @calls_grid.columns.map(&:name).uniq.map do |header|
      [header, I18n.t("datagrid.columns.calls.#{header.to_s}")]
    end.to_h

    number_fields = ['id']
    text_fields = ['information_provided', 'other_more_information', 'brief_note_summary']
    date_picker_fields = ['date_of_call']
    dropdown_list_options = %w(phone_call_id call_type start_datetime referee_id receiving_staff_id answered_call called_before requested_update childsafe_agent protection_concern_id necessity_id not_a_phone_call)

    {
      translation: translations, number_field: number_fields,
      text_field: text_fields, date_picker_field: date_picker_fields,
      dropdown_list_option: get_dropdown_list(dropdown_list_options)
    }
  end

  def get_dropdown_list(dropdown_list_options)
    dropdown_list_options.map do |field_name|
      origin_field_name = field_name
      if ['protection_concern_id', 'necessity_id'].include?(field_name)
        field_name = field_name.gsub('_id', '')
        field_name = field_name.pluralize
      end
      [origin_field_name, CallHelper.send(field_name)]
    end
  end

  def get_basic_field_translations
    I18n.t('calls')
  end

  def true_false_to_yes_no(value)
    if [true, false].include?(value)
      { true => 'Yes', false => 'No' }[value]
    else
      value
    end
  end
  class << self
    def referee_id
      Referee.cache_none_anonymous.map { |referee| { referee.id => referee.name } }
    end

    def receiving_staff_id
      User.cache_case_workers.map { |user| { user.id => user.name } }
    end

    def phone_call_id
      Call.cache_all.map { |phone_call| { phone_call.id => phone_call.id } }
    end

    def call_type
      values = [Call::TYPES, I18n.t('calls.type').values].transpose.to_h
      values.delete('Spam Call')
      values
    end

    def start_datetime
      time_range
    end

    def end_time
      time_range
    end

    def time_range
      times = [{'00' => "12:00AM"}]
      ('01'..'11').each{|d| times << {d => "#{d}:00AM"} }
      ('12'..'23').to_a.zip(['12', *('01'..'11').to_a]).each{|t, d| times << {t => "#{d}:00PM"} }
      times
    end

    def answered_call
      yes_no_dropdown
    end

    def called_before
      yes_no_dropdown
    end

    def requested_update
      yes_no_dropdown
    end

    def childsafe_agent
      yes_no_dropdown
    end

    def protection_concerns
      ProtectionConcern.cache_all.map { |protection_concern| { protection_concern.id => protection_concern.content } }
    end
    
    def necessities
      Necessity.cache_all.map { |necessity| { necessity.id => necessity.content } }
    end

    def not_a_phone_call
      yes_no_dropdown
    end

    def yes_no_dropdown
      { true: 'Yes', false: 'No' }
    end
  end
end
