class ClientEnrollmentGrid
  include Datagrid

  scope do
    ProgramStream.all
  end

  column(:status, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.status') } ) do |object|
    render partial: 'client_enrollments/status', locals: { object: object } 
  end

  column(:name, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.name') } ) do |object|
    link_to object.name, program_stream_path(object)
  end

  column(:domain, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.domain') } ) do |object|
    object.domains.pluck(:identity).join(', ')
  end 

  column(:report, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.report') } ) do |object|
    link_to t('.view'), report_client_client_enrollments_path(@client, program_stream_id: object)
  end

  column(:manage, header: -> { I18n.t('datagrid.columns.client_enrollments.action') }, html: true ) do |object|
    render partial: 'client_enrollments/manage', locals: { object: object }
  end

end
