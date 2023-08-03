module AdvancedSearches
  class RiskAssessmentFields
    extend AdvancedSearchHelper
    extend ApplicationHelper

    def self.render
      address_translation
      group = format_header('risk_assessment')
      level_of_risks = ['level_of_risk'].map { |item| drop_list_options(item, map_level_of_risks, group) }
      date_of_risk_assessment = ['date_of_risk_assessment'].map { |item| date_picker_options(item, item, group) }
      protection_concern_lists = protection_concern_list.map { |k, v| drop_list_options(k, v, group) }
      (level_of_risks + date_of_risk_assessment + protection_concern_lists).sort_by { |f| f[:label].downcase }
    end

    def self.date_picker_options(field_name, _, group)
      {
        id: field_name,
        optgroup: group,
        label: I18n.t('risk_assessments._attr.assessment_date'),
        type: 'date',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty'],
        plugin: 'datepicker',
        plugin_config: {
          format: 'yyyy-mm-dd',
          todayBtn: 'linked',
          todayHighlight: true,
          autoclose: true
        }
      }
    end

    def self.drop_list_options(field_name, options, group)
      field_translation = field_name == 'level_of_risk' ? 'current_level_of_risk' : field_name
      {
        id: field_name,
        optgroup: group,
        label: I18n.t("risk_assessments._attr.#{field_translation}"),
        field: I18n.t("risk_assessments._attr.#{field_translation}"),
        type: 'string',
        input: 'select',
        plugin: 'select2',
        values: options.to_h,
        data: { values: options.to_h },
        operators: ['equal', 'not_equal', 'is_empty', 'is_not_empty']
      }
    end

    def self.map_level_of_risks
      [Referral::LEVEL_OF_RISK, I18n.t('risk_assessments._attr.level_of_risks').values].transpose
    end

    def self.protection_concern_list
      yes_no_options = { true: 'Yes', false: 'No' }
      [
        ['has_hiv_or_aid', yes_no_options],
        ['has_disability', yes_no_options],
        ['has_known_chronic_disease', yes_no_options]
      ]
    end
  end
end
