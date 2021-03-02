class CommunityGrid < BaseGrid
  extend ActionView::Helpers::TextHelper
  include ApplicationHelper
  include CommunityHelper
  include FormBuilderHelper
  include ClientsHelper

  attr_accessor :current_user, :qType, :dynamic_columns, :param_data
  scope do
    Community.includes(:village, :commune, :district, :province, :community_members).order(:name)
  end

  filter(:name, :string, header: -> { I18n.t('activerecord.attributes.community.name') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:name_en, :string, header: -> { I18n.t('activerecord.attributes.community.name_en') }) do |value, scope|
    scope.name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('activerecord.attributes.community.id') })

  filter(:status, :enum, select: Family::STATUSES, header: -> { I18n.t('activerecord.attributes.community.status') }) do |value, scope|
    scope.by_status(value)
  end

  filter(:gender, :enum, select: :gender_options, header: -> { I18n.t('activerecord.attributes.community.gender') })
  filter(:role, header: -> { I18n.t('activerecord.attributes.community.role') })

  filter(:formed_date, :date, header: -> { I18n.t('activerecord.attributes.community.formed_date') })

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

  column(:id, header: -> { I18n.t('activerecord.attributes.community.id') })

  column(:name, order: 'LOWER(name)', header: -> { I18n.t('activerecord.attributes.community.name') }) do |object|
    format(object.name) do |value|
      link_to entity_name(object), community_path(object)
    end
  end

  column(:name_en, order: 'LOWER(name_en)', header: -> { I18n.t('activerecord.attributes.community.name_en') }) do |object|
    format(object.name_en) do |value|
      entity_name(object)
    end
  end

  column(:status, header: -> { I18n.t('activerecord.attributes.community.status') }) do |object|
    object.status.titleize
  end

  column(:gender, header: -> { I18n.t('activerecord.attributes.community.gender') }) do |object|
    gender = object.gender
    gender.present? ? I18n.t("gender_list.#{gender.gsub('other', 'other_gender')}") : ''
  end

  column(:role, header: -> { I18n.t('activerecord.attributes.community.role') })

  column(:formed_date, header: -> { I18n.t('activerecord.attributes.community.formed_date') })
  column(:initial_referral_date, header: -> { I18n.t('activerecord.attributes.community.initial_referral_date') })

  column(:representative_name, header: -> { I18n.t('activerecord.attributes.community.representative_name') })

  column(:phone_number, header: -> { I18n.t('activerecord.attributes.community.phone_number') })

  column(:village_id, order: 'villages.name_kh', header: -> { I18n.t('activerecord.attributes.community.village_id') }) do |object|
    object.village_name
  end

  column(:commune_id, order: 'communes.name_kh', header: -> { I18n.t('activerecord.attributes.community.commune_id') }) do |object|
    object.commune_name
  end

  column(:district_id, order: 'districts.name', header: -> { I18n.t('activerecord.attributes.community.district_id') }) do |object|
    object.district_name
  end

  column(:province_id, order: 'provinces.name', header: -> { I18n.t('activerecord.attributes.community.province_id') }) do |object|
    object.province_name
  end

  column(:direct_beneficiaries, header: -> { Community.human_attribute_name(:direct_beneficiaries) }) do |object|
    object.direct_beneficiaries
  end

  column(:indirect_beneficiaries, header: -> { Community.human_attribute_name(:indirect_beneficiaries) }) do |object|
    object.indirect_beneficiaries
  end

  column(:received_by_id, header: -> { I18n.t('activerecord.attributes.community.received_by_id') }) do |object|
    object.received_by.name
  end

  dynamic do
    next unless dynamic_columns.present?
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }) do |object|
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
        format(properties) do |properties|
          render partial: 'shared/form_builder_dynamic/properties_value', locals: { properties:  properties }
        end
      end
    end
  end

  dynamic do
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?
    quantitative_types = QuantitativeType.joins(:quantitative_cases).where('quantitative_types.visible_on LIKE ?', "%community%").distinct
    quantitative_types.each do |quantitative_type|
      if current_user.nil? || quantitative_type_readable_ids.include?(quantitative_type.id)
        column(quantitative_type.name.to_sym, class: 'quantitative-type', header: -> { quantitative_type.name }, html: true) do |object|
          quantitative_type_values = object.quantitative_cases.where(quantitative_type_id: quantitative_type.id).pluck(:value)
          rule = get_community_rule(params, quantitative_type.name.squish)
          if rule.presence && rule.dig(:type) == 'date'
            quantitative_type_values = date_condition_filter(rule, quantitative_type_values)
          elsif rule.present?
            if rule.dig(:input) == 'select'
              quantitative_type_values = select_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            else
              quantitative_type_values = string_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            end
          end
          quantitative_type_values.join(', ')
        end
      end
    end
  end
end
