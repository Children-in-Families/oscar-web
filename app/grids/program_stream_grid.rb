class ProgramStreamGrid
  include Datagrid

  scope do
    ProgramStream.all
  end

  column(:name, html: true, header: -> { I18n.t('datagrid.columns.program_streams.name') } )
  column(:domains, html: true, header: -> { I18n.t('datagrid.columns.program_streams.domain') } ) do |object|
    object.domains.pluck(:identity).join(', ')
  end
  column(:quantity, html: true, header: -> { I18n.t('datagrid.columns.program_streams.quantity') } )
  column(:action, header: -> { I18n.t('datagrid.columns.program_streams.action') }, html: true, class: 'text-center') do |object|
    render partial: 'program_streams/actions', locals: { object: object }
  end

end
