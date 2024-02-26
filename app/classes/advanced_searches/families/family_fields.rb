module AdvancedSearches
  module Families
    class FamilyFields
      include AdvancedSearchHelper
      include AdvancedSearchFieldHelper
      include FamiliesHelper
      include Pundit

      attr_reader :current_setting

      def initialize(options = {})
        @user = options[:user]
        @pundit_user = options[:pundit_user]
        @called_in = options[:called_in]
        @current_setting = Setting.first
        address_translation
      end

      def render
        group = family_header('family_basic_fields')
        common_group = format_header('common_searches')

        number_fields = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, family_header(item), group) }
        text_fields = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, family_header(item), group) }
        date_picker_fields = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, family_header(item), group) }
        date_picker_fields += common_search_date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, family_header(item), common_group) }
        date_picker_fields += [['no_case_note_date', I18n.t('advanced_search.fields.no_case_note_date')]].map { |item| AdvancedSearches::CsiFields.date_between_only_options(item[0], item[1], group) }
        drop_list_fields = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, family_header(item.first), item.last, group) }
        date_picker_fields += mapping_care_plan_date_lable_translation unless current_setting.try(:hide_family_case_management_tool?)
        search_fields = text_fields + drop_list_fields + number_fields + date_picker_fields

        unless current_setting.hide_family_case_management_tool?
          search_fields += current_setting.enable_custom_assessment? ? AdvancedSearches::CustomDomainScoreFields.render('family') : []
        end

        search_fields.select do |field|
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
        ['created_at', 'date_of_birth', 'contract_date', !current_setting.try(:hide_family_case_management_tool?) ? 'case_note_date' : nil].compact
      end

      def drop_down_type_list
        case_management_tool_fields = if !current_setting.try(:hide_family_case_management_tool?)
                                        [
                                          ['case_note_type', case_note_type_options],
                                          ['case_workers', user_select_options],
                                          ['referral_source_category_id', referral_source_category_options('Family')],
                                          ['referral_source_id', referral_source_options('Family')],
                                          ['followed_up_by_id', followed_up_by_options('Family')]
                                        ]
                                      else
                                        []
                                      end
        [
          ['family_type', family_type_options],
          ['status', status_options],
          ['gender', gender_options],
          ['dependable_income', { yes: 'Yes', no: 'No' }],
          ['client_id', clients],
          ['id_poor', family_id_poor],
          ['user_id', created_by_options('Family')],
          ['received_by_id', received_by_options('Family')],
          ['active_program_stream', active_program_options],
          ['relation', drop_down_relation.map { |k, v| { k => v } }],
          *addresses_mapping(@called_in)
        ] + case_management_tool_fields
      end

      def common_search_date_type_list
        ['number_family_referred_gatekeeping', 'number_family_billable', 'family_rejected', 'active_families']
      end

      def case_note_type_options
        [CaseNote::INTERACTION_TYPE, I18n.t('case_notes.form.type_options').values].transpose.map { |k, v| { k => v } }
      end

      def family_type_options
        Family.mapping_family_type_translation.to_h
      end

      def status_options
        Family::STATUSES
      end

      def clients
        Client.joins(:families).order('lower(clients.given_name)').pluck('clients.given_name, clients.family_name, clients.id').uniq.map { |s| { s[2].to_s => "#{s[0]} #{s[1]}" } }
      end

      def family_id_poor
        Family::ID_POOR.map { |s| { s => s } }
      end

      def case_workers_options
        user_ids = Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:user_id).uniq
        User.where(id: user_ids).order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
      end

      def gender_options
        FamilyMember.gender.values.map { |value| [value, I18n.t("datagrid.columns.families.gender_list.#{value.gsub('other', 'other_gender')}")] }.to_h
      end

      def active_program_options
        Enrollment.cache_program_steams.map { |p| { p.id => p.name } }
      end
    end
  end
end
