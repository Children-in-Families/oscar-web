require 'stringio'

Datagrid.module_eval do
  def to_xls(*column_names)
    book = Spreadsheet::Workbook.new
    book.create_worksheet
    book.worksheet(0).insert_row(0, self.header(*column_names))
    date_format = Spreadsheet::Format.new :number_format => 'DD/MM/YYYY'

    each_with_batches.with_index do |asset, index|
      book.worksheet(0).insert_row (index + 1), row_for(asset, *column_names).map(&:to_s)
    end

    header.each_with_index do |value, index|
      if value.downcase.include?('date') || value.downcase.include?('កាលបរិច្ឆេទ') || value.downcase.include?('ថ្ងៃ') || value.downcase.include?('ေမြးဖြာသည့္') || value.downcase.include?('နေ့စှဲ')
        book.worksheet(0).column(index).default_format = date_format
      end
    end

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end
end
