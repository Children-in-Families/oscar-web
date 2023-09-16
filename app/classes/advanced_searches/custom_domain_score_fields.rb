module AdvancedSearches
  class CustomDomainScoreFields
    extend AdvancedSearchHelper

    def self.render(domain_type = 'client')
      domain_type == 'client' ? render_client_fields(domain_type) : render_family_fields(domain_type)
    end

    def self.render_client_fields(domain_type)
      domain_score_group  = 'Custom Assessment'
      custom_assessment_fields = []
      custom_assessment_fields += ['custom_assessment'].map { |item| drop_list_options(item, format_header(item, domain_type), domain_score_group) }
      custom_assessment_fields += ['custom_completed_date'].map { |item| date_picker_options(item, format_header(item, domain_type), domain_score_group) }
      custom_assessment_fields += ['custom_assessment_created_at', 'date_of_custom_assessments'].map { |item| date_picker_options(item, format_header(item, domain_type), domain_score_group) }
      custom_assessment_fields += ['All Custom Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }

      CustomAssessmentSetting.cache_only_enable_custom_assessment.each do |cas|
        domain_score_group = "#{format_header('custom_csi_domain_scores', domain_type)} | #{cas.custom_assessment_name}"
        domain_options_ = Domain.custom_csi_domains.order_by_identity.where(custom_assessment_setting_id: cas.id).map { |domain| "domainscore__#{domain.id}__#{domain.identity}" }
        custom_assessment_fields += domain_options_.map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      end

      custom_assessment_fields.sort_by { |f| f[:label].downcase }
    end
    
    def self.render_family_fields(domain_type)
      domain_score_group  = format_header('custom_csi_domain_scores', domain_type)
      csi_domain_options  = domain_options.map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
      custom_assessments = ['custom_assessment'].map { |item| drop_list_options(item, format_header(item, domain_type), domain_score_group) }
      assessment_completed_date = ['custom_completed_date'].map { |item| date_picker_options(item, format_header(item, domain_type), domain_score_group) }
      date_of_assessments = ['date_of_custom_assessments', 'custom_assessment_created_at'].map { |item| date_picker_options(item, format_header(item, domain_type), domain_score_group) }
      all_custom_domains  = ['All Custom Domains'].map { |item| number_filter_type(item.downcase.gsub(' ', '_'), domain_score_format(item), domain_score_group) }
      (custom_assessments + date_of_assessments + assessment_completed_date + csi_domain_options + all_custom_domains).sort_by { |f| f[:label].downcase }
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
      values = ('1'..'10').map {|s| { s => s }  }
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

    def self.drop_list_options(field_name, label, group)
      values = CustomAssessmentSetting.cache_all.map {|item| { item.id => item.custom_assessment_name }  }

      {
        id: field_name,
        field: label,
        optgroup: group,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        plugin: 'select2',
        data: { values: values },
        operators: ['equal', 'not_equal', 'is_empty', 'is_not_empty']
      }
    end
  end
end
