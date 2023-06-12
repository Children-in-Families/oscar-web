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

    insert_case_note(book) if include_case_note?
    insert_csi(book) if include_csi?

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read 
  end

  def insert_case_note(book)
    book.create_worksheet(name: 'Case Note')
    book.worksheet(@next_workspace_index).insert_row(0, case_note_headers)
    index = 0
    client_count = 0

    assets.includes(:case_notes).each do |client|
      client.case_notes.sort_by(&:meeting_date).reverse.each_with_index do |case_note, i|
        book.worksheet(@next_workspace_index).insert_row(index += 1, [
          (i == 0 ? (client_count += 1) : ''),
          client.slug,
          client.given_name,
          client.family_name,
          case_note.meeting_date&.strftime('%Y-%m-%d'),
          case_note.interaction_type,
          case_note.attendee,
          case_note.note
        ])
      end
    end

    @next_workspace_index += 1
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
            [assessment_domain.score, assessment_domain.domain.send("score_#{assessment_domain.score}_local_definition")]
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

  private

  def include_case_note?
    instance_of?(ClientGrid) && columns.map(&:name).any? { |column| [:case_note_date, :case_note_type].include?(column) }
  end

  def include_csi?
    csi_columns = csi_identities
    csi_columns += [:all_csi_assessments, :assessment_created_at, :completed_date]

    instance_of?(ClientGrid) && columns.map(&:name).any? { |column| csi_columns.include?(column) }
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
