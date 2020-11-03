class CallsGrid

  include Datagrid

  scope do
    Call.includes(:referee, :receiving_staff, :protection_concerns, :necessities)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.calls.id') })
  filter(:phone_call_id, :enum, select: :phone_call_ids, header: -> { I18n.t('datagrid.columns.calls.phone_call_id') })
  filter(:call_type, :enum, select: :call_type_options, header: -> { I18n.t('datagrid.columns.calls.call_type') })
  filter(:referee_id, :enum, select: :referee_options, header: -> { I18n.t('datagrid.columns.calls.referee_id') })
  filter(:receiving_staff_id, :enum, select: :receiving_staff_options, header: -> { I18n.t('datagrid.columns.calls.receiving_staff_id') })
  filter(:date_of_call, :date, range: true, header: -> { I18n.t('datagrid.columns.calls.date_of_call') })
  filter(:answered_call, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.answered_call') })
  filter(:called_before, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.called_before') })
  filter(:childsafe_agent, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.childsafe_agent') })
  filter(:requested_update, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.requested_update') })
  filter(:information_provided, header: -> { I18n.t('datagrid.columns.calls.information_provided') })
  filter(:not_a_phone_call, select: :yes_no, header: -> { I18n.t('datagrid.columns.calls.not_a_phone_call') })

  column(:id, header: -> { I18n.t('datagrid.columns.calls.id') })
  column(:phone_call_id, header: -> { I18n.t('datagrid.columns.calls.phone_call_id') })
  column(:call_type, header: -> { I18n.t('datagrid.columns.calls.call_type') }) do |object|
    I18n.t("datagrid.columns.calls.types.#{object.call_type.parameterize.underscore}")
  end
  column(:referee_id, order: proc { |object| object.joins(:referee).order("referees.name") }, header: -> { I18n.t('datagrid.columns.calls.referee_id') }) do |object|
    object.referee.try(:name)
  end
  column(:receiving_staff_id, order: proc { |object| object.joins(:receiving_staff).order('users.first_name, users.last_name') }, header: -> { I18n.t('datagrid.columns.calls.receiving_staff_id') } ) do |object|
    object.receiving_staff.try(:name)
  end

  column(:date_of_call, html: true, header: -> { I18n.t('datagrid.columns.calls.date_of_call') }) do |object|
    object.date_of_call.present? ? object.date_of_call.strftime("%d %B %Y") : ''
  end

  column(:date_of_call, html: false, header: -> { I18n.t('datagrid.columns.calls.date_of_call') }) do |object|
    object.date_of_call.present? ? object.date_of_call : ''
  end

  column(:start_datetime, header: -> { I18n.t('datagrid.columns.calls.start_datetime') }) do |model|
    model.start_datetime && model.start_datetime.strftime("%I:%M%p")
  end

  column(:answered_call, order: false, header: -> { I18n.t('datagrid.columns.calls.answered_call') }) do |object|
    object.answered_call == true ? 'Yes' : 'No'
  end
  column(:called_before, order: false, header: -> { I18n.t('datagrid.columns.calls.called_before') }) do |object|
    object.called_before == true ? 'Yes' : 'No'
  end
  column(:childsafe_agent, order: false, header: -> { I18n.t('datagrid.columns.calls.childsafe_agent') }) do |object|
    object.childsafe_agent == true ? 'Yes' : 'No'
  end
  column(:requested_update, order: false, header: -> { I18n.t('datagrid.columns.calls.requested_update') }) do |object|
    object.requested_update == true ? 'Yes' : 'No'
  end
  column(:information_provided, order: false, header: -> { I18n.t('datagrid.columns.calls.information_provided') })
  column(:protection_concern_id, order: false, header: -> { I18n.t('datagrid.columns.calls.protection_concern_id') }) do |object|
    object.protection_concerns.present? ? object.protection_concerns.pluck(:content).join(', ') : ''
  end
  column(:necessity_id, order: false, header: -> { I18n.t('datagrid.columns.calls.necessity_id') }) do |object|
    object.necessities.present? ? object.necessities.pluck(:content).join(', ') : ''
  end
  column(:not_a_phone_call, order: false, header: -> { I18n.t('datagrid.columns.calls.not_a_phone_call') }) do |object|
    object.not_a_phone_call == true ? 'Yes' : 'No'
  end

  column(:other_more_information, order: false, header: -> { I18n.t('datagrid.columns.calls.other_more_information') })
  column(:brief_note_summary, order: false, header: -> { I18n.t('datagrid.columns.calls.brief_note_summary') })

  def phone_call_ids
    Call.pluck(:phone_call_id)
  end

  def call_type_options
    Call::TYPES.map{|type| [I18n.t("datagrid.columns.calls.types.#{type.parameterize.underscore}"), type]}
  end

  def referee_options
    Referee.where(anonymous: false).pluck(:name, :id)
  end

  def receiving_staff_options
    User.all.map{|user| [user.name, user.id] }
  end

  def yes_no
    [[I18n.t('datagrid.columns.calls.has_dob'), 'Yes'], [I18n.t('datagrid.columns.calls.no_dob'), 'No']]
  end
end
