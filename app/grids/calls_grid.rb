class CallsGrid

  include Datagrid

  scope do
    Call.includes(:referee, :receiving_staff)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.calls.id') })
  filter(:phone_call_id, :enum, select: :phone_call_ids, header: -> { I18n.t('datagrid.columns.calls.phone_call_id') })
  filter(:call_type, :enum, select: :call_type_options, header: -> { I18n.t('datagrid.columns.calls.call_type') })
  filter(:referee_id, :enum, select: :referee_options, header: -> { I18n.t('datagrid.columns.calls.referee_id') })
  filter(:receiving_staff_id, :enum, select: :receiving_staff_options, header: -> { I18n.t('datagrid.columns.calls.receiving_staff_id') })
  filter(:start_datetime, :date, header: -> { I18n.t('datagrid.columns.calls.start_datetime') })
  filter(:end_datetime, :date, header: -> { I18n.t('datagrid.columns.calls.end_datetime') })
  filter(:answered_call, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.answered_call') })
  filter(:called_before, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.called_before') })
  filter(:requested_update, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.requested_update') })
  filter(:information_provided, header: -> { I18n.t('datagrid.columns.calls.information_provided') })

  column(:id, header: -> { I18n.t('datagrid.columns.calls.id') })
  column(:phone_call_id, header: -> { I18n.t('datagrid.columns.calls.phone_call_id') })
  column(:call_type, header: -> { I18n.t('datagrid.columns.calls.call_type') }) do |object|
    I18n.t("datagrid.columns.calls.types.#{object.call_type.parameterize.underscore}")
  end
  column(:referee, order: proc { |object| object.joins(:referee).order("referees.name") }, header: -> { I18n.t('datagrid.columns.calls.referee_id') }) do |object|
    object.referee.try(:name)
  end
  column(:receiving_staff, order: proc { |object| object.joins(:receiving_staff).order('users.first_name, users.last_name') }, header: -> { I18n.t('datagrid.columns.calls.receiving_staff_id') } ) do |object|
    object.receiving_staff.try(:name)
  end
  column(:start_datetime, header: -> { I18n.t('datagrid.columns.calls.start_datetime') }) do |model|
    model.start_datetime && model.start_datetime.strftime("%I:%M%p")
  end
  column(:end_datetime, header: -> { I18n.t('datagrid.columns.calls.end_datetime') }) do |model|
    model.end_datetime && model.end_datetime.strftime("%I:%M%p")
  end
  column(:answered_call, order: false, header: -> { I18n.t('datagrid.columns.calls.answered_call') }) do |object|
    object.answered_call == true ? 'Yes' : 'No'
  end
  column(:called_before, order: false, header: -> { I18n.t('datagrid.columns.calls.called_before') }) do |object|
    object.called_before == true ? 'Yes' : 'No'
  end
  column(:requested_update, order: false, header: -> { I18n.t('datagrid.columns.calls.requested_update') }) do |object|
    object.requested_update == true ? 'Yes' : 'No'
  end
  column(:information_provided, order: false, header: -> { I18n.t('datagrid.columns.calls.information_provided') })
  # column(:action, header: -> { I18n.t('datagrid.columns.calls.manage') }, html: true, class: 'text-center') do |object|
  #   render partial: 'calls/actions', locals: { object: object }
  # end
  def phone_call_ids
    Call.pluck(:phone_call_id)
  end

  def call_type_options
    Call::TYPES.zip(Call::TYPES)
  end

  def referee_options
    Referee.all.pluck(:name, :id)
  end

  def receiving_staff_options
    User.all.map{|user| [user.name, user.id] }
  end

  def yes_no
    [[I18n.t('datagrid.columns.calls.has_dob'), 'Yes'], [I18n.t('datagrid.columns.calls.no_dob'), 'No']]
  end
end
