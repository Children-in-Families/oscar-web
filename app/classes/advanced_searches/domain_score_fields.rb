module AdvancedSearches
  class DomainScoreFields
    extend AdvancedSearchHelper

    def self.render
      address_translation
      domain_score_group  = format_header('csi_domain_scores')
      csi_domain_options  = domain_options.map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      assessments_created_at = [['assessment_created_at', I18n.t('clients.index.assessment_created_at', assessment: I18n.t('clients.show.assessment'))]].map { |item| date_picker_options(item[0], item[1], domain_score_group) }
      date_of_assessments = [['date_of_assessments', I18n.t('clients.index.date_of_assessment', assessment: I18n.t('clients.show.assessment'))]].map { |item| date_picker_options(item[0], item[1], domain_score_group) }
      completed_date_assessments = [['completed_date', I18n.t('advanced_search.fields.assessment_completed_date', assessment: I18n.t('clients.show.assessment'))]].map { |item| date_picker_options(item[0], item[1], domain_score_group) }
      all_domains         = ['All Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }
      drop_list_fields = dropdown_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, domain_score_group) }
      # assessment_completed = [['assessment_completed', I18n.t('clients.index.assessment_completed', assessment: I18n.t('clients.show.assessment'))]].map { |item| date_between_only_options(item[0], item[1], domain_score_group) }
      (csi_domain_options + assessments_created_at + date_of_assessments + completed_date_assessments + all_domains + drop_list_fields).sort_by { |f| f[:label].downcase }
    end

    def self.domain_options
      Rails.cache.fetch([Apartment::Tenant.current, 'Domain', 'csi_domains.order_by_identity', 'options']) do
        Domain.csi_domains.order_by_identity.map { |domain| "domainscore__#{domain.id}__#{domain.identity}" }
      end
    end

    def self.domain_score_format(label)
      label.split('__').last
    end

    def self.date_picker_options(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        field: label,
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

    def self.number_filter_type(field_name, label, group)
      values = ['1', '2', '3', '4'].map { |s| { s => s }  }
      {
        id: field_name,
        optgroup: group,
        label: label,
        field: label,
        type: 'string',
        input: 'number',
        values: ['1', '2', '3', '4'],
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty', 'average', 'assessment_has_changed', 'assessment_has_not_changed', 'month_has_changed', 'month_has_not_changed']
      }
    end

    def self.dropdown_list
      yes_no_options = { true: 'Yes', false: 'No' }
      [
        ['has_overdue_assessment', yes_no_options],
      ].compact
    end

    def self.date_between_only_options(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'date',
        operators: ['between'],
        plugin: 'datepicker',
        plugin_config: {
          format: 'yyyy-mm-dd',
          todayBtn: 'linked',
          todayHighlight: true,
          autoclose: true
        }
      }
    end
  end
end
