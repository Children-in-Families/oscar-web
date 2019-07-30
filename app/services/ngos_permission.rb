module NgosPermission
  class Update
    attr_accessor :path, :workbook
    def initialize(sheet_name, path)
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def users
      users = []
      sheet = workbook.sheet(@sheet_name)
      (2..sheet.last_row).each_with_index do |row_index, index|
        data = sheet.row(row_index)

        user = User.find(data[0])
        next if user.blank?
        user.manager_id = nil
        user.manager_ids = []
        user.save(validate: false)

        user.manager_id = data[14].present? ? data[14].to_i : nil
        manager_ids = data[15].present? ? data[15].split(',').map(&:to_i) : []
        user.manager_ids = [data[14].to_i, manager_ids].flatten.compact.uniq
        user.save(validate: false)
      end
    end
  end
end
