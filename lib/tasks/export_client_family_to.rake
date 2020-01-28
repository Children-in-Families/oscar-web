namespace :export_client_family_to do
  desc "Export client family with case worker"
  task excel: :environment do
    headers = ['org_name', 'client_id', 'client_name', 'family_id', 'family_name', 'case_work_name']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')
    client_ids = [1268, 723, 1553, 1361, 1288, 1286, 624, 1440, 1080, 1360, 668, 643, 1225, 762, 1162, 1504, 1438, 1382, 1404, 1506, 1558, 1236, 1507, 1348, 1369, 694, 1456, 1248, 1402, 1132, 724, 693, 1470, 1045, 483, 1302, 1123, 1183, 648, 736, 734, 1555, 649, 1391, 1454, 625, 1422, 1133, 1465, 695, 1216, 1459, 1451, 719, 1245, 1453, 646, 725, 1124, 1403, 1455, 1240, 1435, 1393, 766, 1520, 1207, 1460, 1436, 765, 1370, 1439, 735, 1452, 1392, 647, 1252, 1287, 1381, 1251, 1141]
    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared' || short_name != 'cif'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.where(id: client_ids).each do |client|
        family = Family.where('children && ARRAY[?]', client.id).last
        columns = [
                short_name, client.slug, client.en_and_local_name,
                family.id, family.name,
                client.case_worker_clients.joins(:user).where(users: { roles: 'case worker' }).map{|cwc| "#{cwc.user.name} (#{cwc.user.id})" }.join(', ')
              ]

        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end

end
