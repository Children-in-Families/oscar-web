class ClientUsageReport
  include SpreadsheetHelper
  include ClientByGenderCountHelper

  attr_accessor :client_worksheet
  attr_reader :client_length_of_column

  def initialize(client_worksheet,  beginning_of_previous_month)
    # @client_worksheet = workbook.create_worksheet(name: "3. Client Report-#{beginning_of_previous_month}")
    @client_worksheet = client_worksheet
    @client_length_of_column = client_columns.length
    format_rows_and_columns
  end

  def client_columns
    [
      'Organization', 'Added new client this month',
      'Increased client as adult female', 'Increased client as adult female with disability',
      'Increased client as adult male', 'Increased client as adult male with disability',
      'Increased client as Girl', 'Increased client as Girl with disability',
      'Increased client as Boy', 'Increased client as Boy with disability',
      'Other', 'No DoB']
  end

  def format_rows_and_columns
    client_worksheet.insert_row(0, client_columns)
    client_worksheet.row(0).default_format = header_format

    client_worksheet.row(0).height = 30
    client_length_of_column.times do |index|
      if index.zero?
        client_worksheet.column(index).width = 30
      else
        client_worksheet.column(index).width = 15
      end
    end
  end

  def generate(ngo_name, index,  beginning_of_previous_month, end_of_previous_month)
    ngo_clients = ngo_clients_info(beginning_of_previous_month, end_of_previous_month)
    client_values = [ngo_name, *ngo_clients.values]

    client_worksheet.insert_row(index, client_values)

    client_worksheet.row(index).default_format = column_format
  end

  private

  def ngo_clients_info(beginning_of_month, end_of_month)
    previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
    clients = Client.without_test_clients.where(id:  previous_month_clients.where(event: 'create').pluck(:item_id))
    {
      client_added_count: clients.count,
      new_adult_female_client: adule_client_gender_count(clients, :female),
      new_adult_female_with_disability: adult_with_disability(clients, :female),
      new_adult_male_clients: adule_client_gender_count(clients),
      new_adult_male_with_disability: adult_with_disability(clients, :male),
      new_girl_clients: under_18_client_gender_count(clients, :female),
      new_girl_with_disability: child_with_disability(clients, :female),
      new_boy_clients: under_18_client_gender_count(clients),
      new_boy_with_disability: child_with_disability(clients, :male),
      no_gender_dob_clients: other_client_gender_count(clients),
      no_dob_clients: clients.where("gender IS NOT NULL AND (gender NOT IN ('male', 'female') AND date_of_birth IS NULL)").count
    }
  end

  def adult_with_disability(clients, type = :male)
    age_sql_string = <<-SQL.squish
      (CASE WHEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) ELSE 0 END)
    SQL
    clients.joins(:risk_assessment).public_send(type).where(risk_assessments: { has_disability: true }).where("#{age_sql_string} >= ?", 18).count
  end

  def child_with_disability(clients, type = :male)
    age_sql_string = <<-SQL.squish
      (CASE WHEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) ELSE 0 END)
    SQL
    clients.joins(:risk_assessment).public_send(type).where(risk_assessments: { has_disability: true }).where("#{age_sql_string} < ?", 18).count
  end
end
