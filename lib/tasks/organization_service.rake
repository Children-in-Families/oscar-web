require 'axlsx'
namespace :organization_service do
  desc "TODO"
  task export: :environment do
    p = Axlsx::Package.new
    workbook = p.workbook

    total_header = workbook.styles.add_style fg_color: "FFFFFF",
                              b: true,
                              bg_color: "004586",
                              sz: 10,
                              shrink_to_fit: true,
                              border: { style: :thin, color: "00" },
                              alignment: {  horizontal: :center,
                                            shrink_to_fit: true
                                          }

    highlight_cell_data = workbook.styles.add_style b: false,
                                              sz: 8,
                                              font_name: 'Khmer OS Content',
                                              border: { style: :thin, color: "00" },
                                              alignment: { horizontal: :center,
                                                          shrink_to_fit: true
                                                        }

    Organization.where.not(short_name: 'shared').pluck(:full_name, :short_name).each do |full_name, short_name|
      Organization.switch_to short_name
      setting = Setting.first

      workbook.add_worksheet(:name => "#{full_name[0..24]}(#{short_name})") do |sheet|
        headers = ['Province', 'District', 'Commune']
        sheet.add_row ["#{full_name}(#{short_name})"], style: total_header
        sheet.add_row []
        sheet.add_row ['Location'], style: total_header
        sheet.add_row headers, style: total_header
        sheet.add_row [setting.province&.name, setting.district&.name, setting.commune&.name], style: highlight_cell_data

        sheet.add_row []
        sheet.add_row ["Services"], style: total_header

        headers = Hash.new{|hash, key| hash[key] = Array.new }
        Service.joins(:program_streams).distinct.map{|service| headers[service.parent.name] << service.name }

        if Service.joins(:program_streams).present?
          sheet.add_row headers.keys, style: total_header
          data_cells = Array.new(headers.values.map(&:length).max){|i| headers.values.map{|e| e[i]}}
          data_cells.each do |cell_values|
            sheet.add_row cell_values, style: highlight_cell_data
          end
        end
      end
    end
    p.serialize("organizations.xlsx")
    puts "Done!!!"
  end

end
