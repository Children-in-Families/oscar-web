class RefereesGrid
  include Datagrid
  scope do
    Referee.includes(:province, :district, :commune, :village)
  end
  # id name gender adult anonymous phone email province_id district_id commune_id village_id address_type current_address house_number outside outside_address street_number created_at updated_at)
  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.referees.id') })
  filter(:name, header: -> { I18n.t('datagrid.columns.referees.name') })
  filter(:gender, :enum, select: :gender_list, header: -> { I18n.t('datagrid.columns.referees.gender') })
  filter(:adult, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.referees.adult') })
  filter(:anonymous, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.referees.anonymous') })
  filter(:phone, header: -> { I18n.t('datagrid.columns.referees.phone') })
  filter(:email, header: -> { I18n.t('datagrid.columns.referees.email') })
  filter(:address_type, :enum, select: :address_types, header: -> { I18n.t('datagrid.columns.referees.address_type') })
  filter(:outside, :enum, select: :yes_no, header: -> { I18n.t('datagrid.columns.referees.outside') })
  filter(:created_at, :date, :range => true, header: -> { I18n.t('datagrid.columns.referees.created_at') })

  dynamic do
    yes_no = { true: 'Yes', false: 'No' }
    referee_field_names.each do |field_name|
      value = ''
      column(field_name.to_sym, order: order_field?(field_name), header: -> { I18n.t("datagrid.columns.referees.#{field_name}") }, class: 'referee-field') do |object|
        if field_name[/_id/i]
          address_name = field_name.gsub('_id', '')
          value = object.send(address_name.to_sym).try(:name)
        elsif field_name[/_at/]
          value = object.send(field_name.to_sym).strftime('%d %B %Y')
        else
          value = object.send(field_name.to_sym)
          value = (value == true || value == false) ? yes_no[value.to_s.to_sym] : value
        end
        case field_name
        when 'gender'
          value = value.titleize
        when 'address_type'
          types = address_types.map(&:reverse).to_h
          value = types[value]
        end
        value
      end
    end
  end

  def referee_field_names
    Referee::FIELDS
  end

  def order_field?(field_name)
    order_fields = ['id', 'name', 'gender', 'email']
    order_fields.include?(field_name) ? true : false
  end

  def address_types
    km_types = [["ផ្ទះ", 'home'], ["មុខជំនួញ", 'business'], ["RCI", 'rci'], ["អន្តេវាសិកដ្ឋាន", 'dormitory'], ["ផ្សេងៗ", 'other']]
    en_types = ["Home", "Business", "RCI", "Dormitory", "Other"]
    I18n.locale == :km ? km_types : en_types.map{ |type| [type, type.downcase] }
  end

  def yes_no
    [[I18n.t('datagrid.columns.referees.has_dob'), 'Yes'], [I18n.t('datagrid.columns.referees.no_dob'), 'No']]
  end

  def gender_list
    [Referee::GENDER_OPTIONS.map{|value| I18n.t("default_client_fields.gender_list.#{ value.gsub('other', 'other_gender') }") }, Client::GENDER_OPTIONS].transpose
  end
end
