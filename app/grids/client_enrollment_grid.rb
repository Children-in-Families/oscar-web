class ClientEnrollmentGrid
  include Datagrid

  scope do
    ProgramStream.all
  end

  column(:status, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.status') } ) do |object|
    render partial: 'client_enrollments/status', locals: { object: object } 
  end

  column(:name, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.name') } )

  column(:report, html: true, header: -> { I18n.t('datagrid.columns.client_enrollments.report') } ) do |object|
    link_to t('.view'), report_client_client_enrollments_path(@client, program_stream_id: object)
  end

  column(:manage, header: -> { I18n.t('datagrid.columns.client_enrollments.action') }, html: true ) do |object|
    render partial: 'client_enrollments/manage', locals: { object: object }
  end

end
