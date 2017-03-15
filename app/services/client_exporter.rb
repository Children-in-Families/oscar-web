class ClientExporter
  def self.to_xls(resources)
    headers = format_header(resources.first.attributes.keys)
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
  def self.format_header(columns)
    new_column = ['ID', 'Name']
    columns.each do |col|
      next if col == 'id' || col == 'slug' || col =='first_name'
      new_column.push col.humanize
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
      else
        selected_values.push v.to_s
      end
    end
    id_values + name_values + selected_values
  end
end
