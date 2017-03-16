class ClientExporter
  extend AdvancedSearchHelper

  def self.to_xls(resources)
    headers = rearrange_header(resources.first.attributes.keys)
    book = Spreadsheet::Workbook.new
    book.create_worksheet
    book.worksheet(0).insert_row(0, headers)

    resources.each_with_index do |asset, index|
      book.worksheet(0).insert_row((index + 1), format_result(asset.attributes))
    end

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end

  private

  def self.rearrange_header(columns)
    new_column = []
    new_column.push format_header('slug')
    new_column.push format_header('first_name')
    
    columns.each do |col|
      next if col == 'id' || col == 'slug' || col =='first_name'
      new_column.push format_header(col)
    end
    
    new_column
  end

  def self.format_result(values)
    id_values       = []
    name_values     = []
    selected_values = []
    
    values.each do |k, v|
      next if k == 'id'
      if k == 'slug'
        id_values.push v
      elsif k == 'first_name'
        name_values.push v
      elsif k == 'has_been_in_orphanage' || k == 'has_been_in_government_care'
        selected_values.push(v ? 'Yes' : 'No')
      elsif ['birth_province_id', 'province_id'].include?(k)
        selected_values.push Province.find_by(id: v).try(:name)
      elsif ['referral_source_id'].include?(k)
        selected_values.push ReferralSource.find_by(id: v).try(:name)
      elsif ['received_by_id', 'followed_up_by_id', 'user_id'].include?(k)
        selected_values.push(User.find_by(id: v).try(:name) || '')
      elsif k == 'age'
        client = Client.find_by(date_of_birth: v)
        selected_values.push "#{client.age_as_years} #{'year'.pluralize(client.age_as_years)} #{client.age_extra_months} #{'month'.pluralize(client.age_extra_months)}" if client.present?
      else
        selected_values.push v.to_s
      end
    end
    id_values + name_values + selected_values
  end
end
