module AdvancedSearches
  class CustomDomainScoreFields
    extend AdvancedSearchHelper

    def self.render(domain_type = 'client')
      address_translation
      domain_score_group  = format_header('custom_csi_domain_scores')
      csi_domain_options  = domain_options(domain_type).map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      assessment_completed_date = [['assessment_completed_date', I18n.t('datagrid.columns.assessment_completed_date', assessment: I18n.t('clients.show.assessment'))]].map{ |item| date_picker_options(item[0], item[1], domain_score_group) }
      date_of_assessments = [['date_of_custom_assessments', I18n.t('datagrid.columns.date_of_family_assessment', assessment: I18n.t('clients.show.assessment'))]].map{ |item| date_picker_options(item[0], item[1], domain_score_group) }
      all_custom_domains  = ['All Custom Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }
      date_of_assessments + assessment_completed_date + csi_domain_options + all_custom_domains
    end

    private

    def self.domain_options(domain_type = 'client')
      Domain.cache_domain_options(domain_type)
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
      values = ('1'..'10').map{|s| { s => s }  }
      {
        id: field_name,
        optgroup: group,
        label: label,
        field: label,
        type: 'string',
        input: 'number',
        values: ('1'..'10').to_a,
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty', 'average', 'assessment_has_changed', 'assessment_has_not_changed', 'month_has_changed', 'month_has_not_changed']
      }
    end
  end
end
