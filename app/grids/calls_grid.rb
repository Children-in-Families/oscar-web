class CallsGrid

  include Datagrid

  scope do
    Call.includes(:referee, :receiving_staff)
  end

  filter(:id, :integer)
  filter(:phone_call_id)
  filter(:call_type)
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
    object.referee.name
  end
  column(:receiving_staff, order: proc { |object| object.joins(:receiving_staff).order('users.first_name, users.last_name') }) do |object|
    object.receiving_staff.name
  end
  column(:start_datetime) do |model|
    model.created_at.to_date
  end
  column(:end_datetime) do |model|
    model.created_at.to_date
  end
  column(:information_provided, order: false)
  column(:phone_counselling_summary, order: false)
  # column(:action, header: -> { I18n.t('datagrid.columns.calls.manage') }, html: true, class: 'text-center') do |object|
  #   render partial: 'calls/actions', locals: { object: object }
  # end

  def referee_options
    Referee.all.pluck(:name, :id)
  end

  def receiving_staff_options
    User.case_workers.map{|user| [user.name, user.id] }
  end
end
