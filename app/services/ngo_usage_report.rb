class NgoUsageReport
  include ReferralsHelper
  include SpreadsheetHelper
  include ClientByGenderCountHelper

  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  def ngo_info(org)
    country = Setting.first.present? ? Setting.first.country_name.downcase : ''
    {
      ngo_name: org.full_name,
      ngo_short_name: org.short_name,
      ngo_on_board: org.last_integrated_date,
      created_at: org.created_at.strftime('%d-%m-%Y'),
      fcf: org.fcf_ngo? ? 'Yes' : 'No',
      ngo_country: country.titleize,
      integrated: org.integrated ? 'Yes' : 'No'
    }
  end

  def ngo_users_info(beginning_of_month, end_of_month)
    previous_month_users = PaperTrail::Version.where(item_type: 'User', created_at: beginning_of_month..end_of_month)
    users = User.non_devs.where(id: previous_month_users.where(event: 'create').pluck(:item_id))
    {
      user_count: users.count,
      unlock_users: users.where(disable: true).count,
      female_users: users.where(gender: 'female').count,
      male_users: users.where(gender: 'male').count,
      other_users: users.where.not(gender: ['male', 'female']).count,
      login_per_month: Visit.excludes_non_devs.total_logins(beginning_of_month, end_of_month).count
    }
  end

  def ngo_referrals_info(beginning_of_month, end_of_month)
    tranferred_clients = PaperTrail::Version.where(item_type: 'Referral', event: 'create', created_at: beginning_of_month..end_of_month)
    {
      tranferred_client_count: tranferred_clients.map { |a| a.changeset[:slug] && a.changeset[:slug][1] }.compact.uniq.count
    }
  end

  private

  def import_usage_report(date_time)
    ngo_columns = ['Organization', 'On-board Date', 'FCF', 'Country']
    user_columns = ['Organization', 'No. of Users', 'Unlock User', 'No. of Users Added Female', 'No. of Users Added Male', 'No. of Users Added Other', 'No. of Logins/Month']

    cross_ngo_columns = ['Organization', 'No. of Clients referred', 'Adult Female', 'Adult Male', 'Girl', 'Boy', 'Other', 'Agency Name received the case']

    cross_mosvy_columns_group = ['', '', '', 'NGO to MoSAVY', '', '', '', '', '', 'MoSAVY to NGO', '', '', '', '', '']
    cross_mosvy_columns = ['Organization', 'Sign up date', 'Current Sharing', 'No. of Clients referred', 'Adult Female', 'Adult Male', 'Girl', 'Boy', 'Other', 'No. of Clients received', 'Adult Female', 'Adult Male', 'Girl', 'Boy', 'Other']

    learning_columns = ['Onboarding Date', '', '', '', '', '', 'Number of Logins', '', '']
    sub_learning_columns = ['Started Sharing This Month', '', 'Stopped Sharing This Month', '', 'Currently Sharing (All Time)', '', 'User', 'Organization Name', 'Login Count']

    book = Spreadsheet::Workbook.new

    beginning_of_month = date_time.to_datetime.prev_month.beginning_of_month
    end_of_month = date_time.to_datetime.prev_month.end_of_month
    previous_month = date_time.to_datetime.prev_month.strftime('%B %Y')

    ngo_worksheet = book.create_worksheet(name: "1. NGO Records-#{previous_month}")
    user_worksheet = book.create_worksheet(name: "2. User Report-#{previous_month}")
    client_worksheet = book.create_worksheet(name: "3. Client Report-#{previous_month}")
    ngo_clients = ClientUsageReport.new(client_worksheet, beginning_of_month)
    cross_ngo_worksheet = book.create_worksheet(name: "4. Cross NGO-NGO Report-#{previous_month}")
    cross_mosvy_worksheet = book.create_worksheet(name: "5. Cross NGO-MOSVY Report-#{previous_month}")
    learning_worksheet = book.create_worksheet(name: "6. OSCaR Leaning Report-#{previous_month}")

    ngo_worksheet.insert_row(0, ngo_columns)
    user_worksheet.insert_row(0, user_columns)

    cross_ngo_worksheet.insert_row(0, cross_ngo_columns)

    cross_mosvy_worksheet.insert_row(0, cross_mosvy_columns_group)
    cross_mosvy_worksheet.insert_row(1, cross_mosvy_columns)
    cross_mosvy_worksheet.merge_cells(0, 3, 0, 8)
    cross_mosvy_worksheet.merge_cells(0, 9, 0, 14)
    cross_mosvy_worksheet.row(1).height = 30

    cross_mosvy_columns.length.times do |i|
      cross_mosvy_worksheet.row(0).set_format(i, header_format)
      cross_mosvy_worksheet.row(1).set_format(i, header_format)
    end

    cross_mosvy_worksheet.column(0).width = 35
    cross_mosvy_worksheet.column(1).width = 15
    cross_mosvy_worksheet.column(2).width = 15
    cross_mosvy_worksheet.column(3).width = 20
    cross_mosvy_worksheet.column(4).width = 15
    cross_mosvy_worksheet.column(5).width = 15

    cross_mosvy_worksheet.column(9).width = 20
    cross_mosvy_worksheet.column(10).width = 15
    cross_mosvy_worksheet.column(11).width = 15

    # Leaning worksheet ==================================
    learning_worksheet.insert_row(0, learning_columns)
    learning_worksheet.insert_row(1, sub_learning_columns)

    sub_learning_columns.length.times do |i|
      learning_worksheet.row(0).set_format(i, header_format)
      learning_worksheet.row(1).set_format(i, header_format)
    end
    learning_worksheet.merge_cells(0, 0, 0, 5)
    learning_worksheet.merge_cells(0, 6, 0, 8)
    learning_worksheet.merge_cells(1, 0, 1, 1)
    learning_worksheet.merge_cells(1, 2, 1, 3)
    learning_worksheet.merge_cells(1, 4, 1, 5)

    learning_worksheet.row(0).height = 30
    learning_worksheet.row(1).height = 30
    (0..(sub_learning_columns.size - 1)).each { |index| learning_worksheet.column(index).width = 20 }

    ngo_length_of_column = ngo_columns.length
    user_length_of_column = user_columns.length

    cross_ngo_column_length = cross_ngo_columns.length

    ngo_length_of_column.times do |i|
      ngo_worksheet.row(0).set_format(i, header_format)
    end

    ngo_worksheet.row(0).height = 30
    ngo_worksheet.column(0).width = 35
    ngo_worksheet.column(1).width = 33
    ngo_worksheet.column(2).width = 15
    ngo_worksheet.column(3).width = 20

    user_length_of_column.times do |i|
      user_worksheet.row(0).set_format(i, header_format)
    end

    user_worksheet.row(0).height = 30
    6.times { |index| user_worksheet.column(index).width = 30 }

    cross_ngo_worksheet.row(0).height = 30
    cross_ngo_worksheet.column(0).width = 35
    cross_ngo_worksheet.column(1).width = 35
    cross_ngo_worksheet.column(7).width = 35
    cross_ngo_column_length.times { |i| cross_ngo_worksheet.row(0).set_format(i, header_format) }

    shared_data = []
    stop_sharing_date = []
    all_learning_data = []

    Organization.order(:created_at).where.not(short_name: ['demo', 'tutorials', 'shared']).order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      next if Setting.first.blank?

      setting = ngo_info(org)
      ngo_users = ngo_users_info(beginning_of_month, end_of_month)

      # ngo_referrals         = ngo_referrals_info(beginning_of_month, end_of_month)
      cross_ngo_referrals = cross_ngo_referrals_info(beginning_of_month, end_of_month)
      cross_mosvy_referrals = cross_mosvy_referrals_info(setting, beginning_of_month, end_of_month)

      ngo_values = [setting[:ngo_name], setting[:created_at], setting[:fcf], setting[:ngo_country]]
      user_values = [setting[:ngo_name], *ngo_users.values]
      # client_values       = [setting[:ngo_name], *ngo_clients.values]
      cross_ngo_values = [setting[:ngo_name], *cross_ngo_referrals.values]
      cross_mosvy_values = [setting[:ngo_name], *cross_mosvy_referrals.values]

      start_sharing_data = Setting.first.start_sharing_this_month(date_time)
      stop_sharing_data = Setting.first.stop_sharing_this_month(date_time)
      current_sharing_data = Setting.first.current_sharing_with_research_module

      shared_data << mapping_learning_module_date(setting, start_sharing_data)
      stop_sharing_date << mapping_learning_module_date(setting, stop_sharing_data)
      all_learning_data << mapping_learning_module_date(setting, current_sharing_data)

      ngo_worksheet.insert_row(index + 1, ngo_values)
      user_worksheet.insert_row(index + 1, user_values)
      ngo_clients.generate(setting[:ngo_name], index + 1, beginning_of_month, end_of_month)
      cross_ngo_worksheet.insert_row(index, cross_ngo_values)
      cross_mosvy_worksheet.insert_row(index + 1, cross_mosvy_values)

      ngo_length_of_column.times do |i|
        ngo_worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1

        ngo_worksheet.row(index).set_format(i, column_format)
      end

      user_length_of_column.times do |i|
        user_worksheet.row(index).set_format(i, column_format)
      end

      (0..(sub_learning_columns.size - 1)).each do |i|
        learning_worksheet.row(index + 3).set_format(i, column_format)
      end
    end

    Organization.switch_to 'public'

    user_data = User.where.not('email ILIKE ?', 'api.user@%').map do |user|
      [user.name, user.organization_name, user.sign_in_count]
    end

    learning_index = 0
    (0..(Organization.count)).each do |i|
      start_data = shared_data.compact.presence || [['', '']]
      stop_data = stop_sharing_date.compact.presence || [['', '']]
      all_data = all_learning_data.compact.presence || [['', '']]
      login_data = user_data.compact.presence || [['', '', '']]
      learning_data = [start_data[i] || ['', ''], stop_data[i] || ['', ''], all_data[i] || ['', ''], login_data[i] || ['', '', '']]
      next if learning_data.flatten.reject(&:blank?).blank?
      learning_index = i + 2
      learning_worksheet.insert_row(learning_index, learning_data.flatten)
      sub_learning_columns.length.times.each do |ii|
        learning_worksheet.row(learning_index).set_format(ii, column_format)
      end
    end
    learning_worksheet.insert_row(learning_index + 1, ['TOTAL', shared_data.compact.count, '', stop_sharing_date.compact.count, '', all_learning_data.compact.count, '', '', user_data.compact.map(&:third).sum])
    learning_worksheet.row(learning_index + 1).height = 21
    sub_learning_columns.length.times.each do |i|
      learning_worksheet.row(learning_index + 1).set_format(i, column_format)
    end

    ClientsSyncedReport.new(book, beginning_of_month).generate
    ClientsSyncedMonthlyReport.new(book, beginning_of_month, end_of_month).generate

    book.write("tmp/OSCaR-usage-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end

  def generate(date_time, previous_month)
    NgoUsageReportWorker.perform_async(date_time, previous_month)
  end

  def mapping_learning_module_date(setting, data)
    updated_at_date = data.last['updated_at'].try(:last) || data.last['updated_at'] if data.present?
    [setting[:ngo_short_name].upcase, updated_at_date&.strftime('%d-%m-%Y')]
  end

  def cross_ngo_referrals_info(beginning_of_month, end_of_month)
    referrals = Referral.delivered.where(created_at: beginning_of_month..end_of_month).where('referred_to != ?', 'MoSVY External System')
    clients = Client.where(id: referrals.pluck(:client_id))
    {
      number_of_referrals: referrals.count,
      adult_females: adule_client_gender_count(clients, :female),
      adult_males: adule_client_gender_count(clients),
      girls: under_18_client_gender_count(clients, :female),
      boys: under_18_client_gender_count(clients),
      others: other_client_gender_count(clients),
      referred_to: referrals.map { |referral| referral.ngo_name.presence || ngo_hash_mapping[referral.referred_to] }.join(', ')
    }
  end

  def cross_mosvy_referrals_info(ngo_data, beginning_of_month, end_of_month)
    ngo_to_mosvy_hash = ngo_referral_client_info(beginning_of_month, end_of_month)
    mosvy_to_ngo_hash = mosvy_referral_client_info(beginning_of_month, end_of_month)

    {
      sign_update_date: ngo_data[:ngo_on_board],
      current_sharing: ngo_data[:integrated]
    }.merge(ngo_to_mosvy_hash.merge(mosvy_to_ngo_hash))
  end

  def ngo_referral_client_info(beginning_of_month, end_of_month)
    referrals = Referral.where(created_at: beginning_of_month..end_of_month).where('referred_to = ?', 'MoSVY External System')
    clients = Client.where(id: referrals.pluck(:client_id))
    {
      ngo_mosvy_referred_client_count: referrals.count,
      ngo_mosvy_adult_females: adule_client_gender_count(clients, :female),
      ngo_mosvy_adult_males: adule_client_gender_count(clients, :male),
      ngo_mosvy_girls: under_18_client_gender_count(clients, :female),
      ngo_mosvy_boys: under_18_client_gender_count(clients, :male),
      ngo_mosvy_others: other_client_gender_count(clients)
    }
  end

  def mosvy_referral_client_info(beginning_of_month, end_of_month)
    referrals = Referral.where(created_at: beginning_of_month..end_of_month).where(referred_from: 'MoSVY External System')
    clients = Client.where(id: referrals.pluck(:client_id))
    {
      mosvy_ngo_referred_client_count: referrals.count,
      mosvy_ngo_adult_females: adule_client_gender_count(clients, :female, referrals),
      mosvy_ngo_adult_males: adule_client_gender_count(clients, :male, referrals),
      mosvy_ngo_girls: under_18_client_gender_count(clients, :female, referrals),
      mosvy_ngo_boys: under_18_client_gender_count(clients, :male, referrals),
      mosvy_ngo_others: other_client_gender_count(clients, referrals)
    }
  end
end
