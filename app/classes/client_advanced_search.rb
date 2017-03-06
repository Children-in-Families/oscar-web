class  ClientAdvancedSearch                  
  def initialize(options = {})

    @drop_list_type_fields = [
                            ['gender','Gender', { male: 'Male', female: 'Female' }],
                            ['status', 'Status', client_status],
                            ['birth_province_id', 'Birth province', provinces],
                            ['received_by_id,' 'Received by', received_by_options],
                            ['referral_source_id', 'Referral source', referral_source_options],
                            ['followed_up_by_id', 'Followed-up by', followed_up_by_options],
                            ['has_been_in_government_care', 'Has been in government care', { true: 'Yes', false: 'No' }],
                            ['able_state', 'Able state', client_able_state],
                            ['has_been_in_orphanage', 'Has been in orphanage', { true: 'Yes', false: 'No'}],
                            ['user_id', 'Case Worker', user_select_options]
                          ]

    @user = options[:user]
    @drop_list = {
                  gender: { male: 'Male', female: 'Female' },
                  status: client_status, 
                  # case_type: { EC: 'EC', FC: 'FC', KC: 'KC' },
                  birth_province_id: provinces, 
                  # province_id: provinces,
                  received_by_id: received_by_options,
                  referral_source_id: referral_source_options,
                  followed_up_by_id: followed_up_by_options, 
                  # agency_name: agencies_options, 
                  has_been_in_government_care: { true: 'Yes', false: 'No' }, 
                  able_state: client_able_state,
                  has_been_in_orphanage: { true: 'Yes', false: 'No'},
                  user_id: user_select_options
                }
    @text      = [
                  :first_name, 
                  # :family_name,
                  :id, 
                  :referral_phone, 
                  :school_name]
    @date      = [:palcement_date, :date_of_birth, :initial_referral_date, :follow_up_date]
    @number    = [:code, 
                  # :family_id, 
                  :age, :school_grade]
  end



  def data_fields
    text_fields         = @text.map{ |item| text_options(item.to_s, {label: item.to_s.humanize}) }
    number_fields       = @number.map{ |item| number_options(item.to_s, {label: item.to_s.humanize}) }
    date_picker_fields  = @date.map{ |item| date_picker_options(item.to_s, {label: item.to_s.humanize}) }
    drop_list_fields    = @drop_list_type_fields.map{ |item| drop_list_options(item.first, item.second, item.last)}

    text_fields + drop_list_fields + number_fields + date_picker_fields
  end

  def text_options(field_name, options = {})
    label = options[:label]
    {
      id: field_name,
      label: label,
      type: 'string',
      operators: ['equal', 'not_equal', 'contains', 'not_contains']  
    }
  end

  def number_options(field_name, options = {})
    label = options[:label]

    {
      id: field_name,
      label: label,
      type: 'integer',
      operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between']
    }
  end

  def date_picker_options(field_name, options = {})
    label = options[:label]

    {
      id: field_name,
      label: label,
      type: 'date',
      operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between'],
      plugin: 'datepicker',
      plugin_config: {
        format: 'yyyy-mm-dd',
        todayBtn: 'linked',
        todayHighlight: true,
        autoclose: true
      }
    }
  end

  def drop_list_options(field_name, label, values)
    {
      id: field_name,
      label: label,
      type: 'string',
      input: 'select',
      values: values,
      operators: ['equal', 'not_equal']
    }
  end

  private

  def client_status
    Client::CLIENT_STATUSES.map{ |s| {s => s.capitalize} }
  end

  def client_able_state
    Client::ABLE_STATES.map{ |s| {s => s} }
  end

  def provinces
   Client.province_is.to_h.invert
  end

  def received_by_options
    clients = @user.present? ? Client.where(user_id: @user.id).is_received_by : Client.is_received_by
    clients.to_h.invert
  end

  def referral_source_options
    clients = @user.present? ? Client.where(user_id: @user.id).referral_source_is : Client.referral_source_is
    clients.to_h.invert
  end
  

  def followed_up_by_options
    clients = @user.present? ? Client.where(user_id: @user.id).is_followed_up_by : Client.is_followed_up_by
    clients.to_h.invert
  end

  def agencies_options
    Agency.joins(:clients).pluck(:id, :name).uniq.to_h
  end

  def user_select_options
    User.has_clients.map{ |user| { user.id => user.name } }
  end
end