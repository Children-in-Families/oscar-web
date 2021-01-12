module AdvancedSearches
  class CustomDomainScoreFields
    extend AdvancedSearchHelper

    def self.render(domain_type = 'client')
      domain_score_group  = format_header('custom_csi_domain_scores')
      csi_domain_options  = domain_options(domain_type).map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      date_of_assessments = [['date_of_custom_assessments', I18n.t('clients.index.date_of_custom_assessment', assessment: I18n.t('clients.show.assessment'))]].map{ |item| date_picker_options(item[0], item[1], domain_score_group) }
      all_custom_domains  = ['All Custom Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }
      date_of_assessments + csi_domain_options + all_custom_domains
    end

    private

    def self.domain_options(domain_type = 'client')
      if domain_type == 'family'
        Domain.family_custom_csi_domains.order_by_identity.map { |domain| "domainscore__#{domain.id}__#{domain.identity}" }
      else
        Domain.custom_csi_domains.order_by_identity.map { |domain| "domainscore__#{domain.id}__#{domain.identity}" }
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
