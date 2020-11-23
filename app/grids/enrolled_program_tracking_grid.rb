class EnrolledProgramTrackingGrid
  include Datagrid

  scope do
    Tracking.all
  end
  column(:name, html: true, header: -> { I18n.t('datagrid.columns.trackings.name') } )

  column(:frequency, html: true, header: -> { I18n.t('datagrid.columns.trackings.frequency') } )

  column(:report, html: true, header: -> { I18n.t('datagrid.columns.trackings.report') } ) do |object|
    path = params[:family_id] ? report_family_enrolled_program_enrolled_program_trackings_path(@programmable, @enrollment, tracking_id: object.id) : '#'
    link_to t('.view'), path
  end

  # column(:action, html: true, header: -> { I18n.t('datagrid.columns.trackings.action') } ) do |object|
  #   render partial: 'client_enrolled_program_trackings/action', locals: { object: object }
  # end
end
