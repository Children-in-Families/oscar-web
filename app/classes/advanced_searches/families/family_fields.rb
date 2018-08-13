module AdvancedSearches
  module Families
    class FamilyFields
      include AdvancedSearchHelper

      def render
        group                 = family_header('basic_fields')
        number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, family_header(item), group) }
        text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, family_header(item), group) }
        date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, family_header(item), group) }
        drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, family_header(item.first), item.last, group) }

        search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

        search_fields.sort_by { |f| f[:label].downcase }
      end

      private

      def number_type_list
        ['significant_family_member_count', 'household_income', 'female_children_count', 'male_children_count', 'female_adult_count', 'male_adult_count', 'id']
      end

      def text_type_list
        ['code', 'name', 'caregiver_information', 'case_history', 'street', 'house']
      end

      def date_type_list
        ['contract_date']
      end

      def drop_down_type_list
        [
          ['family_type', family_type_options],
          ['status', status_options],
          ['province_id', provinces],
          ['district_id', districts],
          ['dependable_income', { yes: 'Yes', no: 'No' }],
          ['client_id', clients],
          ['form_title', family_custom_form_options],
          ['commune_id', communes],
          ['village_id', villages]
        ]
      end

      def family_type_options
        Family::TYPES
      end

      def status_options
        Family::STATUSES
      end

      def provinces
        Family.joins(:province).pluck('provinces.name', 'provinces.id').uniq.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def districts
        Family.joins(:district).pluck('districts.name', 'districts.id').uniq.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def communes
        Commune.joins(:families, district: :province).distinct.map{|commune| ["#{commune.name_kh} / #{commune.name_en} (#{commune.code})", commune.id]}.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def villages
        Village.joins(:families, commune: [district: :province]).distinct.map{|village| ["#{village.name_kh} / #{village.name_en} (#{village.code})", village.id]}.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def clients
        Client.joins(:families).order('lower(clients.given_name)').pluck('clients.given_name, clients.family_name, clients.id').uniq.map{|s| { s[2].to_s => "#{s[0]} #{s[1]}" } }
      end

      def family_custom_form_options
        CustomField.joins(:custom_field_properties).family_forms.uniq.map{ |c| { c.id.to_s => c.form_title }}
      end

      def case_workers_options
        user_ids = Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:user_id).uniq
        User.where(id: user_ids).order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
      end
    end
  end
end
