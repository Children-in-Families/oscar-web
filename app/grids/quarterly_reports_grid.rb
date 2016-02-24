class QuarterlyReportsGrid
  include Datagrid

  attr_accessor :current_case

  scope do
    QuarterlyReport.all.includes(:staff_information, :case)
  end

  column(:code, html: true) do |object|
    link_to object.code, client_case_quarterly_report_path(object.case.client, object.case, object)
  end

  column(:visit_date, header: 'Date of Visit', html: true)

  column(:case, header: 'KC Name', html: true) do |object|
    link_to object.case.client.name, client_path(object.case.client) if object.kinship?
  end

  column(:case, header: 'FC Name', html: true) do |object|
    link_to object.case.client.name, client_path(object.case.client) if object.foster?

  end

  column(:general_health_or_appearance, header: 'Describe general Health/Appearance', html: true) do |object|
    truncate(object.general_health_or_appearance, length: 50)
  end

  column(:staff_information, header: 'Staff Information', html: true) do |object|
    link_to object.staff_information.name, user_path(object.staff_information) if object.staff_information
  end
end
