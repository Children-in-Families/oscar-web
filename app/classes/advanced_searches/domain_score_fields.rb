module AdvancedSearches
  class DomainScoreFields
    extend AdvancedSearchHelper

    def self.render
      domain_score_group     = format_header('csi_domain_scores')
      domain_options.map { |item| number_filter_type(item, domain_score_format(item), domain_score_group) }
    end

    private

    def self.domain_options
      Domain.order(:identity).map { |domain| "domainscore_#{domain.id}_#{domain.identity}" }
    end

    def self.domain_score_format(label)
      label.split('_').last
    end

    def self.number_filter_type(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'integer',
        validation: { max: 4, min: 1 },
        operators: ['equal', 'not_equal', 'between']
      }
    end
  end
end
