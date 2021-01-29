module AdvancedSearches
  module Communities
    class CommunityFields
      include AdvancedSearchHelper
      include Pundit

      def initialize(options = {})
        @user = options[:user]
        @pundit_user = options[:pundit_user]
      end

      def render
        group                 = community_header('basic_fields')
        number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, community_header(item), group) }
        text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, community_header(item), group) }
        date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, community_header(item), group) }
        drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, community_header(item.first), item.last, group) }

        search_fields         = text_fields + drop_list_fields + number_fields + date_picker_fields

        search_fields.sort_by { |f| f[:label].downcase }
      end

      private

      def current_user
        @pundit_user
      end

      def number_type_list
        []
      end

      def text_type_list
        ['name', 'phone_number', 'role', 'representative_name']
      end

      def date_type_list
        ['initial_referral_date', 'formed_date']
      end

      def drop_down_type_list
        [
          ['status', status_options],
          ['gender', gender_options]
        ]
      end

      def status_options
        Community::STATUSES
      end

      def gender_options
        Community.gender.values.map{ |value| [value, I18n.t("gender_list.#{value.gsub('other', 'other_gender')}")] }.to_h
      end
    end
  end
end
