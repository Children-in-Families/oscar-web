module SpreadsheetHelper
  def header_format
    Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 12,
      text_wrap: true
    )
  end

  def column_format
    Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11
    )
  end

  def  column_date_format
    Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11,
      number_format: 'mmmm d, yyyy'
    )
  end
end
