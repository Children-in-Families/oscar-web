class RefereesGrid
  include Datagrid
  scope do
    Referee.includes(:province, :district, :commune, :village)
  end
  # id name gender adult anonymous answered_call called_before phone email province_id district_id commune_id village_id address_type current_address house_number outside outside_address requested_update street_number created_at updated_at)
  filter(:id, :integer)
  filter(:name)
  filter(:gender, :enum, select: [['Male', 'male'], ['Female', 'female']])
  filter(:adult, :enum, select: %w(Yes No))
  filter(:anonymous, :enum, select: %w(Yes No))
  filter(:answered_call, :enum, select: %w(Yes No))
  filter(:called_before, :enum, select: %w(Yes No))
  filter(:phone)
  filter(:email)
  filter(:address_type, :enum, select: :address_types)
  filter(:outside, :enum, select: %w(Yes No))
  filter(:requested_update, :enum, select: %w(Yes No))
  filter(:created_at, :date, :range => true)

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
end
