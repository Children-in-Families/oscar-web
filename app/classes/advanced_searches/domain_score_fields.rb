module AdvancedSearches
  class DomainScoreFields
    extend AdvancedSearchHelper

    def self.render
      domain_score_group  = format_header('csi_domain_scores')
      csi_domain_options  = domain_options.map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      date_of_assessments = [['date_of_assessments', I18n.t('clients.index.date_of_assessment', assessment: I18n.t('clients.show.assessment'))]].map{ |item| date_picker_options(item[0], item[1], domain_score_group) }
      all_domains         = ['All Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }
      csi_domain_options + date_of_assessments + all_domains
    end

    private

    def self.domain_options
      Domain.csi_domains.order_by_identity.map { |domain| "domainscore__#{domain.id}__#{domain.identity}" }
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
      values = ['1', '2', '3', '4'].map{ |s| { s => s }  }
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
  end
end
