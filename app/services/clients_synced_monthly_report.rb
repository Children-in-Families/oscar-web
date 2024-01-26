class ClientsSyncedMonthlyReport
  include SpreadsheetHelper
  include ClientByGenderCountHelper

  attr_reader :end_of_previous_month, :beginning_of_previous_month
  attr_accessor :sheet

  def initialize(workbook, beginning_of_previous_month, end_of_previous_month)
    @beginning_of_previous_month = beginning_of_previous_month
    @end_of_previous_month = end_of_previous_month

    @sheet = workbook.create_worksheet(name: "Case synced from Primero Monthly Report-#{beginning_of_previous_month}")
  end

  def columns
    ['Organization sign-up to connect with Primero', '# of case synced this month', 'Female adult case', 'Male adult case', 'Female child case', 'Male child case', 'Other']
  end

  def generate
    set_column_width
    columns.length.times do |i|
      sheet.row(0).set_format(i, header_format)
    end

    sheet.insert_row(0, columns)

    Organization.only_integrated.each_with_index do |ngo, index|
      Apartment::Tenant.switch ngo.short_name
      clients = Client.where('synced_date IS NOT NULL AND DATE(synced_date) BETWEEN ? AND ?', beginning_of_previous_month, end_of_previous_month)

      client_hash = {
        organizations: ngo.full_name_short_name,
        total_count: clients.count,
        adult_females: adule_client_gender_count(clients, :female),
        adult_males: adule_client_gender_count(clients),
        girls: under_18_client_gender_count(clients, :female),
        boys: under_18_client_gender_count(clients),
        others: other_client_gender_count(clients)
      }

      sheet.insert_row(index + 1, client_hash.values)
    end
  end

  def set_column_width
    (0..columns.length - 1).each do |i|
      if i.zero?
        sheet.column(i).width = 55
      else
        sheet.column(i).width = 15
      end
    end
  end
end
