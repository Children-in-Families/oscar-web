class TrackingGrid
  include Datagrid

  scope do
    Tracking.all
  end
  column(:name, html: true, header: -> { I18n.t('datagrid.columns.trackings.name') } )

  column(:frequency, html: true, header: -> { I18n.t('datagrid.columns.trackings.frequency') } )

  column(:report, html: true, header: -> { I18n.t('datagrid.columns.trackings.report') } ) do |object|
    link_to t('.view'), report_client_client_enrollment_client_enrollment_trackings_path(@client, @enrollment, tracking_id: object.id)
  end
end
