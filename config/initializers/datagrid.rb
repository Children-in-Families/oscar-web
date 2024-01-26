require 'stringio'
include FormBuilderHelper

Datagrid.module_eval do
  def to_xls(*column_names)
    book = Spreadsheet::Workbook.new
    book.create_worksheet
    @next_workspace_index = 1

    book.worksheet(0).insert_row(0, self.header(*column_names))

    each_with_batches.with_index do |asset, index|
      book.worksheet(0).insert_row (index + 1), row_for(asset, *column_names).map(&:to_s)
    end

    if instance_of?(ClientGrid)
      insert_case_note(book) if include_case_note?
      insert_csi(book) if include_csi?
      insert_custom_assessment(book) if include_custom_assessment?
      insert_care_plan(book) if include_care_plan?
      insert_custom_forms(book) if include_custom_forms?
    end

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end

  def insert_case_note(book)
    rows = []
    client_count = 0

    assets.each do |client|
      case_notes = case_note_query(client.case_notes.most_recents, 'case_note_date')

      case_notes.each_with_index do |case_note, i|
        rows << [
          (i == 0 ? (client_count += 1) : ''),
          client.slug,
          client.given_name,
          client.family_name,
          case_note.meeting_date&.strftime('%Y-%m-%d'),
          case_note.interaction_type,
          case_note.attendee,
          case_note.note
        ]
      end
    end

    if rows.any?
      book.create_worksheet(name: 'Case Note')
      book.worksheet(@next_workspace_index).insert_row(0, case_note_headers)

      rows.each_with_index do |row, index|
        book.worksheet(@next_workspace_index).insert_row(index += 1, row)
      end

      @next_workspace_index += 1
    end
  end

  def insert_custom_forms(book)
    custom_forms = CustomField.where(entity_type: "Client", form_title: custom_form_selected_columns.keys.map{ |key| key.to_s.split('__').second })
    clients = assets.includes(:custom_field_properties).where(custom_field_properties: { custom_field_id: custom_forms.ids }).to_a

    custom_forms.each do |custom_form|
      fields = custom_form.fields.reject{ |field| field['type'] == 'file' }.map{ |f| f['label']}

      rows = []
      client_count = 0
      rows << [
        '#',
        'Client ID',
        'Custom Form #',
        'Created Date',
        *fields
      ]

      clients.each do |client|
        custom_field_properties = client.custom_field_properties.select{ |custom_field_property| custom_field_property.custom_field_id == custom_form.id }
        next if custom_field_properties.blank?

        custom_field_properties.sort_by(&:created_at).reverse.each_with_index do |custom_field_property, i|
          answers = fields.map do |field|
            answer = custom_field_property_answer(field, custom_field_property)
            answer = answer.join(" | ") if answer.is_a?(Array)
            answer
          end

          rows << [
            (i == 0 ? (client_count += 1) : ''),
            client.slug,
            (i + 1).ordinalize,
            custom_field_property.created_at&.strftime('%Y-%m-%d'),
            *answers
          ]
        end
      end

      if rows.size > 1
        book.create_worksheet(name: custom_form.form_title)

        rows.each_with_index do |row, index|
          book.worksheet(@next_workspace_index).insert_row(index, row)
        end

        @next_workspace_index += 1
      end
    end
  end

  def insert_csi(book)
    book.create_worksheet(name: 'CSI Assessment')
    book.worksheet(@next_workspace_index).insert_row(0, csi_headers)
    index = 0
    client_count = 0

    assets.includes(default_most_recents_assessments: [assessment_domains: :domain]).each do |client|
      client.default_most_recents_assessments.reverse.each_with_index do |assessment, i|
        dynamic_columns = Domain.csi_domains.order_by_identity.pluck(:identity).map do |identity|
          assessment_domain = assessment.assessment_domains.find{ |ad| ad.domain.identity == identity }

          if assessment_domain&.score
            description = assessment_domain.domain.send("translate_score_#{assessment_domain.score}_definition")
            description ||= assessment_domain.domain.send("score_#{assessment_domain.score}_local_definition")

            [assessment_domain.score, description]
          else
            ['', '']
          end
        end

        row = [
          (i == 0 ? (client_count += 1) : ''),
          client.slug,
          client.given_name,
          client.family_name,
          (i + 1).ordinalize,
          assessment.created_at&.strftime('%Y-%m-%d'),
          assessment.completed_date&.strftime('%Y-%m-%d'),
          *dynamic_columns.flatten
        ]

        book.worksheet(@next_workspace_index).insert_row(index += 1, row)
      end
    end

    @next_workspace_index += 1
  end

  def insert_custom_assessment(book)
    book.create_worksheet(name: "#{custom_assessment_setting.custom_assessment_name} Assessment")
    book.worksheet(@next_workspace_index).insert_row(0, custom_assessment_headers)
    index = 0
    client_count = 0

    assets.includes(custom_assessments: [assessment_domains: :domain]).each do |client|
      ordinal = 0
      client.custom_assessments.sort_by(&:created_at).reverse.each_with_index do |assessment, i|
        next if assessment.custom_assessment_setting_id != assessment_setting_id.to_i

        dynamic_columns = Domain.custom_csi_domains.where(custom_assessment_setting_id: assessment_setting_id).order_by_identity.pluck(:identity).map do |identity|
          assessment_domain = assessment.assessment_domains.find{ |ad| ad.domain.identity == identity }

          if assessment_domain&.score
            description = assessment_domain.domain.send("translate_score_#{assessment_domain.score}_definition")
            description ||= assessment_domain.domain.send("score_#{assessment_domain.score}_local_definition")

            [assessment_domain.score, description]
          else
            ['', '']
          end
        end

        row = [
          (ordinal == 0 ? (client_count += 1) : ''),
          client.slug,
          client.given_name,
          client.family_name,
          (ordinal + 1).ordinalize,
          assessment.created_at&.strftime('%Y-%m-%d'),
          assessment.completed_date&.strftime('%Y-%m-%d'),
          *dynamic_columns.flatten
        ]

        ordinal += 1
        book.worksheet(@next_workspace_index).insert_row(index += 1, row)
      end
    end

    @next_workspace_index += 1
  end

  def insert_care_plan(book)
    book.create_worksheet(name: 'Care Plan')
    book.worksheet(@next_workspace_index).insert_row(0, care_plan_headers)

    index = 0
    client_count = 0
    domain_identities = Domain.where(id: AssessmentDomain.joins(goals: :care_plan).distinct.pluck(:domain_id)).order_by_identity.pluck(:identity)

    assets.includes(care_plans: [goals: :assessment_domain]).each do |client|
      client.care_plans.sort_by{ |c| c.care_plan_date || client.created_at }.reverse.each_with_index do |care_plan, i|
        dynamic_columns = domain_identities.map do |identity|
          goal = care_plan.goals.find{ |g| g.assessment_domain&.domain.identity == identity }
          goal&.description
        end

        next if dynamic_columns.all?(&:blank?)

        row = [
          (i == 0 ? (client_count += 1) : ''),
          client.slug,
          (i + 1).ordinalize,
          care_plan.care_plan_date&.strftime('%Y-%m-%d'),
          care_plan.created_at&.strftime('%Y-%m-%d'),
          *dynamic_columns
        ]

        book.worksheet(@next_workspace_index).insert_row(index += 1, row)
      end
    end

    @next_workspace_index += 1
  end

  private

  def include_case_note?
    columns.map(&:name).any? { |column| [:case_note_date, :case_note_type].include?(column) }
  end

  def include_csi?
    csi_columns = csi_identities
    csi_columns += [:all_csi_assessments, :assessment_created_at, :completed_date]

    columns.map(&:name).any? { |column| csi_columns.include?(column) }
  end

  def include_care_plan?
    care_plan_columns = [:care_plan_date, :care_plan_completed_date, :care_plan_count]
    columns.map(&:name).any? { |column| care_plan_columns.include?(column) }
  end

  def care_plan_headers
    [
      '#',
      'Client ID',
      'Care plan #',
      column_by_name(:care_plan_date).to_s,
      column_by_name(:care_plan_completed_date).to_s,
      *care_plan_dynamic_columns
    ]
  end

  def care_plan_dynamic_columns
    @care_plan_dynamic_columns ||= care_plan_identities.map{ |column| "Goal for #{column_by_name(column)}" }
  end

  def care_plan_identities
    @care_plan_identities ||= Domain.where(id: AssessmentDomain.joins(goals: :care_plan).distinct.pluck(:domain_id)).order_by_identity.map(&:convert_identity).map(&:to_sym)
  end

  def case_note_headers
    [
      '#',
      'Client ID',
      column_by_name(:given_name).to_s,
      column_by_name(:family_name).to_s,
      column_by_name(:case_note_date).to_s,
      column_by_name(:case_note_type).to_s,
      'Who was there during the visit or conversation',
      'Note'
    ]
  end

  def csi_headers
    [
      '#',
      'Client ID',
      column_by_name(:given_name).to_s,
      column_by_name(:family_name).to_s,
      'Assessment # (Ordinal Numbers)',
      'Assessment Created At',
      'Assessment Completed Date',
      *csi_dynamic_columns
    ]
  end

  def csi_dynamic_columns
    @csi_dynamic_columns ||= csi_identities.map{ |column| ['', column_by_name(column).to_s] }.flatten
  end

  def csi_identities
    @csi_identities ||= Domain.csi_domains.order_by_identity.map(&:convert_identity).map(&:to_sym)
  end

  def custom_assessment_headers
    [
      '#',
      'Client ID',
      column_by_name(:given_name).to_s,
      column_by_name(:family_name).to_s,
      'Assessment # (Ordinal Numbers)',
      'Assessment Created At',
      'Assessment Completed Date',
      *custom_assessment_dynamic_columns
    ]
  end

  def include_custom_assessment?
    custom_assessment_columns = custom_assessment_identities
    custom_assessment_columns += [:custom_assessment_created_at, :date_of_custom_assessments, :custom_assessment, :custom_completed_date]

    custom_assessment_setting.present? && columns.map(&:name).any? { |column| custom_assessment_columns.include?(column) }
  end

  def custom_assessment_dynamic_columns
    @custom_assessment_dynamic_columns ||= custom_assessment_identities.map{ |column| ['', column_by_name(column).to_s] }.flatten
  end

  def custom_assessment_identities
    @custom_assessment_identities ||= Domain.custom_csi_domains.where(custom_assessment_setting_id: assessment_setting_id).order_by_identity.map{ |item| "custom_#{item.convert_identity}".to_sym }
  end

  def include_custom_forms?
    custom_form_selected_columns.present?
  end

  def custom_form_selected_columns
    params.respond_to?(:select) && params.select { |key, value| key.to_s.start_with?('formbuilder__') } || {}
  end

  def custom_field_property_answer(field_name, custom_field_property)
    answer = custom_field_property.properties[field_name]

    if answer.blank?
      field_name = field_name.gsub(/\s+/, "").gsub(/[^0-9A-Za-z]/, '')
      answer = custom_field_property.properties.find { |key, value| key.to_s.gsub(/\s+/, "").gsub(/[^0-9A-Za-z]/, '') == field_name }&.last
    end

    if answer.blank?
      matching_keys = custom_field_property.properties.map do |field, _value|
        matching_count = field.gsub(/\s+/, "").gsub(/[^0-9A-Za-z]/, '').chars.zip(field_name.chars).take_while { |a,b| a == b }.count

        [field, matching_count] if matching_count > 0
      end.compact

      if matching_keys.any?
        actual_key = matching_keys.sort_by{ |k| k.last }.last.first
        answer = custom_field_property.properties[actual_key]
      end
    end

    answer
  end
end

Datagrid.configure do |config|

  # Defines date formats that can be used to parse date.
  # Note that multiple formats can be specified but only first format used to format date as string.
  # Other formats are just used for parsing date from string in case your App uses multiple.
  config.date_formats = ["%d %B %Y", "%Y-%m-%d"]

  # Defines timestamp formats that can be used to parse timestamp.
  # Note that multiple formats can be specified but only first format used to format timestamp as string.
  # Other formats are just used for parsing timestamp from string in case your App uses multiple.
  config.datetime_formats = ["%m/%d/%Y %h:%M", "%Y-%m-%d %h:%M:%s"]
end
