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
        ['name', 'name_en']
      end

      def date_type_list
        ['initial_referral_date', 'formed_date']
      end

      def drop_down_type_list
        [
          ['status', status_options],
          ['province_id', provinces],
          ['district_id', districts],
          ['commune_id', communes],
          ['village_id', villages]
        ]
      end

      def community_type_options
        Community.mapping_community_type_translation.to_h
      end

      def status_options
        Community::STATUSES
      end

      def provinces
        Community.joins(:province).pluck('provinces.name', 'provinces.id').uniq.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def districts
        Community.joins(:district).pluck('districts.name', 'districts.id').uniq.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def communes
        Commune.joins(:families, district: :province).distinct.map{|commune| ["#{commune.name_kh} / #{commune.name_en} (#{commune.code})", commune.id]}.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def villages
        Village.joins(:families, commune: [district: :province]).distinct.map{|village| ["#{village.name_kh} / #{village.name_en} (#{village.code})", village.id]}.sort.map{|s| {s[1].to_s => s[0]}}
      end

      def clients
        Client.joins(:families).order('lower(clients.given_name)').pluck('clients.given_name, clients.community_name, clients.id').uniq.map{|s| { s[2].to_s => "#{s[0]} #{s[1]}" } }
      end

      def case_workers_options
        user_ids = Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true }).pluck(:user_id).uniq
        User.where(id: user_ids).order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
      end

      def gender_options
        CommunityMember.gender.values.map{ |value| [value, I18n.t("datagrid.columns.families.gender_list.#{value.gsub('other', 'other_gender')}")] }.to_h
      end
    end
  end
end
