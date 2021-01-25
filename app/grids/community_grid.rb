class CommunityGrid < BaseGrid
  include ClientsHelper

  attr_accessor :dynamic_columns

  scope do
    Community.includes(:village, :commune, :district, :province, :community_members).order(:name)
  end

  filter(:name, :string, header: -> { Community.human_attribute_name(:name) }) do |value, scope|
    scope.name_like(value)
  end

  filter(:name_en, :string, header: -> { Community.human_attribute_name(:name_en) }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { Community.human_attribute_name(:id) })

  filter(:status, :enum, select: Family::STATUSES, header: -> { Community.human_attribute_name(:status) }) do |value, scope|
    scope.by_status(value)
  end

  filter(:gender, :enum, select: :gender_options, header: -> { Community.human_attribute_name(:gender) })

  filter(:formed_date, :date, header: -> { Community.human_attribute_name(:formed_date) })

  def commune_options
    Community.joins(:commune).map{|f| [f.commune.code_format, f.commune_id]}.uniq
  end

  def village_options
    Community.joins(:village).map{|f| [f.village.code_format, f.village_id]}.uniq
  end

  def province_options
    Community.province_are
  end

  def district_options
    Community.joins(:district).pluck('districts.name', 'districts.id').uniq
  end

  def gender_options
    Community.gender.values.map{ |value| [I18n.t("datagrid.columns.families.gender_list.#{value.gsub('other', 'other_gender')}"), value] }
  end

  column(:id, header: -> { Community.human_attribute_name(:id) })

  column(:name, html: true, order: 'LOWER(name)', header: -> { Community.human_attribute_name(:name) }) do |object|
    link_to entity_name(object), community_path(object)
  end

  column(:name_en, html: true, order: 'LOWER(name_en)', header: -> { Community.human_attribute_name(:name_en) }) do |object|
    entity_name(object)
  end

  column(:status, header: -> { Community.human_attribute_name(:status) }) do |object|
    object.status.titleize
  end

  column(:village, order: 'villages.name_kh', header: -> { Community.human_attribute_name(:village) }) do |object|
    object.village_name
  end

  column(:commune, order: 'communes.name_kh', header: -> { Community.human_attribute_name(:commune) }) do |object|
    object.commune_name
  end

  column(:district, order: 'districts.name', header: -> { Community.human_attribute_name(:district) }) do |object|
    object.district_name
  end

  column(:province, order: 'provinces.name', header: -> { Community.human_attribute_name(:province) }) do |object|
    object.province_name
  end

  dynamic do
    next unless dynamic_columns.present?
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        if fields.last == 'Has This Form'
          properties = [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Family'}).count]
        else
          properties_field = 'custom_field_properties.properties'
          format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')

          basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
          basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
          results      = mapping_form_builder_param_value(basic_rules, 'formbuilder')

          query_string = get_query_string(results, 'formbuilder', properties_field)
          sql          = query_string.reverse.reject(&:blank?).map{|sql| "(#{sql})" }.join(" AND ")

          properties   = object.custom_field_properties.joins(:custom_field).where(sql).where(custom_fields: { form_title: fields.second, entity_type: 'Community'}).properties_by(format_field_value)
        end
        render partial: 'shared/form_builder_dynamic/properties_value', locals: { properties:  properties }
      end

    end
  end
end
