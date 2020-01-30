class CallsGrid

  include Datagrid

  scope do
    Call.includes(:referee, :receiving_staff)
  end

  filter(:id, :integer)
  filter(:phone_call_id, :enum, select: :phone_call_ids)
  filter(:call_type, :enum, select: :call_type_options)
  filter(:referee_id, :enum, select: :referee_options)
  filter(:receiving_staff_id, :enum, select: :receiving_staff_options)
  filter(:start_datetime, :date)
  filter(:end_datetime, :date)
  filter(:information_provided)
  filter(:phone_counselling_summary)

  column(:id)
  column(:phone_call_id, header: 'Phone call ID')
  column(:call_type)
  column(:referee, order: proc { |object| object.joins(:referee).order("referees.name") }) do |object|
    object.referee.try(:name)
  end
  column(:receiving_staff, order: proc { |object| object.joins(:receiving_staff).order('users.first_name, users.last_name') }) do |object|
    object.receiving_staff.try(:name)
  end
  column(:start_datetime) do |model|
    model.start_datetime && model.start_datetime.strftime("%I:%M%p")
  end
  column(:end_datetime) do |model|
    model.end_datetime && model.end_datetime.strftime("%I:%M%p")
  end
  column(:information_provided, order: false)
  column(:phone_counselling_summary, order: false)
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
end
