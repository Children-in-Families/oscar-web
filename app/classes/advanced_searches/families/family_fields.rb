module AdvancedSearches
  module Families
    class FamilyFields
      include AdvancedSearchHelper
      include AdvancedSearchFieldHelper
      include Pundit

      def initialize(options = {})
        @user = options[:user]
        @pundit_user = options[:pundit_user]
      end

      def render
        group                 = family_header('family_basic_fields')
        number_fields         = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, family_header(item), group) }
        text_fields           = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, family_header(item), group) }
        date_picker_fields    = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, family_header(item), group) }
        drop_list_fields      = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, family_header(item.first), item.last, group) }
        date_picker_fields    += mapping_care_plan_date_lable_translation
        search_fields = text_fields + drop_list_fields + number_fields + date_picker_fields
        custom_domain_scores_options = !Setting.first.hide_family_case_management_tool? ? AdvancedSearches::CustomDomainScoreFields.render('family') : []

        (search_fields.sort_by { |f| f[:label].downcase } + custom_domain_scores_options).select do |field|
          field_name = field[:id]
          field_name = 'member_count' if field_name.to_s.include?('significant_family_member_count')
          policy(Family).show?(field_name.to_sym)
        end
      end

      private

      def current_user
        @pundit_user
      end

      def number_type_list
        ['significant_family_member_count', 'household_income', 'female_children_count', 'male_children_count', 'female_adult_count', 'male_adult_count', 'id']
      end

      def text_type_list
        ['code', 'name', 'name_en', 'phone_number', 'caregiver_information', 'case_history', 'street', 'house']
      end

      def date_type_list
        ['date_of_birth', 'contract_date', 'case_note_date', 'active_families']
      end

      def drop_down_type_list
        [
          ['case_note_type', case_note_type_options],
          ['family_type', family_type_options],
          ['status', status_options],
          ['gender', gender_options],
          ['province_id', provinces],
          ['district_id', districts],
          ['dependable_income', { yes: 'Yes', no: 'No' }],
          ['case_workers', user_select_options],
          ['client_id', clients],
          ['commune_id', communes],
          ['village_id', villages],
          ['id_poor', family_id_poor],
          ['received_by_id', received_by_options('Family')],
          ['followed_up_by_id', followed_up_by_options('Family')],
          ['referral_source_category_id', referral_source_category_options('Family')],
          ['referral_source_id', referral_source_options('Family')],
        ]
      end

      def case_note_type_options
        [CaseNote::INTERACTION_TYPE, I18n.t('case_notes.form.type_options').values].transpose.map { |k, v| { k => v }  }
      end

      def family_type_options
        Family.mapping_family_type_translation.to_h
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

      def family_id_poor
        Family::ID_POOR.map { |s| { s => s } }
      end

      def case_workers_options
        user_ids = Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:user_id).uniq
        User.where(id: user_ids).order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
      end

      def gender_options
        FamilyMember.gender.values.map{ |value| [value, I18n.t("datagrid.columns.families.gender_list.#{value.gsub('other', 'other_gender')}")] }.to_h
      end
    end
  end
end
