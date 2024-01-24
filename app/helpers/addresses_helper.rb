module AddressesHelper
  def selected_country
    country = Organization.current.country || Setting.cache_first.try(:country_name) || params[:country].presence
    country.nil? ? 'cambodia' : country
  end

  def country_address_field(object)
    country = selected_country
    current_address = []
    current_address << translate_address_field(object, 'house_number')
    current_address << translate_address_field(object, 'street_number')

    case country
    when 'thailand'
      current_address << object.plot if object.plot.present?
      current_address << object.road if object.road.present?
      current_address << object.subdistrict_name if object.subdistrict.present?
      current_address << object.district_name if object.district.present?
      current_address << object.province_name if object.province.present?
      current_address << object.postal_code if object.postal_code.present?
      current_address << 'Thailand'
    when 'lesotho'
      current_address << object.suburb if object.suburb.present?
      current_address << object.description_house_landmark if object.description_house_landmark.present?
      current_address << object.directions if object.directions.present?
      current_address << 'Lesotho'
    when 'myanmar'
      current_address << object.street_line1 if object.street_line1.present?
      current_address << object.street_line2 if object.street_line2.present?
      current_address << object.township_name if object.township.present?
      current_address << object.state_name if object.state.present?
      current_address << 'Myanmar'
    when 'uganda'
      current_address = merged_address(object)
    when 'indonesia'
      current_address << object.subdistrict_name if object.subdistrict.present?
      current_address << object.district_name if object.district.present?
      current_address << object.city_name if object.city.present?
      current_address << object.province_name if object.province.present?
      current_address << object.postal_code if object.try(:postal_code).present?
      current_address << 'Indonesia'
    else
      current_address = merged_address(object)
    end
    current_address.compact.join(', ')
  end

  def merged_address(object)
    current_address = []
    current_address << translate_address_field(object, 'house_number')
    current_address << translate_address_field(object, 'street_number')
    current_address << translate_address_field(object, 'village')
    current_address << translate_address_field(object, 'commune')

    if I18n.locale.to_s == 'km'
      current_address << object.district_name.split(' / ').first if object.district.present?
      current_address << object.province_name.split(' / ').first if object.province.present?
      current_address << 'កម្ពុជា' if Organization.current.short_name != 'brc'
    else
      current_address << object.district_name.split(' / ').last if object.district.present?
      current_address << object.province_name.split(' / ').last if object.province.present?
      current_address << 'Cambodia' if Organization.current.short_name != 'brc'
    end
    current_address
  end

  def translate_address_field(object, field)
    klass_name = (object.class.name[/Decorator/] ? object.object : object).class.name.downcase.pluralize

    if I18n.locale.to_s == 'km'
      "#{I18n.t("datagrid.columns.#{klass_name}.#{field}")} #{object.try(field).try(:name_kh) || object.try(field)}" if object.try(field).present?
    elsif object.methods.include?(field) || object.try(field).present?
      "#{I18n.t("datagrid.columns.#{klass_name}.#{field}")} #{object.try(field).try(:name_en) || object.try(field)}"
    end
  end
end
