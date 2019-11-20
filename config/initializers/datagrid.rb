require 'stringio'
include FormBuilderHelper

Datagrid.module_eval do
  def to_xls(*column_names)
    book = Spreadsheet::Workbook.new
    book.create_worksheet
    book.worksheet(0).insert_row(0, self.header(*column_names))

    each_with_batches.with_index do |asset, index|
      book.worksheet(0).insert_row (index + 1), row_for(asset, *column_names).map(&:to_s)
    end

    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end
end
