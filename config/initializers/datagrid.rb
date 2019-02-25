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
      date_string = ['date', 'កាលបរិច្ឆេទ', 'កាលបរិចេ្ឆទនៃការបញ្ជូនដំបូង', 'ថ្ងៃ', 'ေမြးဖြာသည့္', 'နေ့စှဲ', 'ေမြးရက္၊ လ၊ ႏွစ္', 'ရက္စြဲ']
      date_string.each do |date|
        if value.downcase.include?(date)
          book.worksheet(0).column(index).default_format = date_format
        end
      end
    end

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end
end
