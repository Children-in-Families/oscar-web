module AdvancedSearches
  module Partners
    class PartnerFields
      include AdvancedSearchHelper

      def render
        group                 = partner_header('basic_fields')
        number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, partner_header(item), group) }
        text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, partner_header(item), group) }
        date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, partner_header(item), group) }
        drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, partner_header(item.first), item.last, group) }

        search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

        search_fields.sort_by { |f| f[:label].downcase }
      end

      private

      def number_type_list
        ['id']
      end

      def text_type_list
        ['name', 'contact_person_name', 'contact_person_email', 'contact_person_mobile', 'organisation_type', 'engagement', 'affiliation', 'address', 'background']
      end

      def date_type_list
        ['start_date']
      end

      def drop_down_type_list
        [
          ['province_id', provinces],
          ['form_title', partner_custom_form_options]
        ]
      end

      def provinces
        Partner.joins(:province).pluck('provinces.name', 'provinces.id').uniq.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def partner_custom_form_options
        CustomField.joins(:custom_field_properties).partner_forms.uniq.map{ |c| { c.id.to_s => c.form_title }}
      end
    end
  end
end
