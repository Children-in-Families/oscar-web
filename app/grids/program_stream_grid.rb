class ProgramStreamGrid
  include Datagrid

  scope do
    ProgramStream.all
  end

  column(:name, html: true, header: -> { I18n.t('datagrid.columns.program_streams.name') } )
  column(:description, html: true, header: -> { I18n.t('datagrid.columns.program_streams.description') } )
  column(:action, header: -> { I18n.t('datagrid.columns.program_streams.action') }, html: true, class: 'text-center') do |object|
    render partial: 'program_streams/actions', locals: { object: object }
  end

end
