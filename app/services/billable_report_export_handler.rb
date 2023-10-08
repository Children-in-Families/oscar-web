class BillableReportExportHandler
  def self.call(report, file_name)
    new(report, file_name).call
  end

  attr_reader :report, :file_name

  def initialize(report, file_name)
    @report = report
    @file_name = file_name
  end

  
  def call
    Organization.switch_to(report.organization.short_name)
    book = Spreadsheet::Workbook.new

    add_client_sheet(book)
    add_family_sheet(book)
    book.write(file_name)
  end

  private

  def add_client_sheet(book)
    headers = [
      'Client ID',
      'Created Date',
      'Accepted/Acitve Date',
      'Billable Status',
      'Current Status',
      'Case Worker'
    ]

    sheet = book.create_worksheet(name: "Billable clients #{ report.month }-#{report.year}")
    sheet.insert_row(0, headers)
    
    report.billable_report_items.client.where.not(billable_at: nil).includes(:version, :billable).each_with_index do |client_item, index|
      version = client_item.version
      client = client_item.billable || Client.new(version.object)
      
      sheet.insert_row((index + 1), [
        client.slug,
        client.created_at.strftime('%d/%m/%Y'),
        version.created_at.strftime('%d/%m/%Y'),
        client_item.billable_status,
        client.status,
        client.users.uniq.map(&:name).join(', ')
      ])
    end
  end

  def add_family_sheet(book)
    headers = [
      'Fmily ID',
      'Created Date',
      'Accepted/Acitve Date',
      'Billable Status',
      'Current Status',
      'Case Worker'
    ]

    sheet = book.create_worksheet(name: "Billable families #{ report.month }-#{report.year}")
    sheet.insert_row 0, headers
    
    report.billable_report_items.family.where.not(billable_at: nil).includes(:version, :billable).each_with_index do |family_item, index|
      family = family_item.billable
      version = family_item.version

      sheet.insert_row((index + 1), [
        family.id,
        family.created_at.strftime('%d/%m/%Y'),
        version.created_at.strftime('%d/%m/%Y'),
        family_item.billable_status,
        family.status,
        family.case_workers.uniq.map(&:name).join(', ')
      ])
    end
  end
end
