module AssessmentHelper
  def assessment_edit_link(client, assessment)
    if assessment_editable?
      link_to(edit_client_assessment_path(assessment.client, assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if(false, edit_client_assessment_path(assessment.client, assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def assessment_destroy_link(client, assessment)
    if assessment_deleted?
      link_to(client_assessment_path(assessment.client, assessment), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if(false, client_assessment_path(assessment.client, assessment), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def order_assessment
    if action_name == 'edit'
      @assessment.assessment_domains_in_order
    end
  end

  def assessment_readable?
    return true if current_user.admin? || current_user.strategic_overviewer?
    current_user.permission.assessments_readable
  end

  def assessment_editable?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.permission.assessments_editable
  end

  def assessment_deleted?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
  end

  def assessment_completed_date(assessment)
    if assessment.completed?
      completed_date = PaperTrail::Version.where(item_type: 'Assessment', item_id: assessment.id).where_object_changes(completed: true).last.created_at
    else
      completed_date = assessment.created_at
    end
    completed_date
  end

  def is_domain_definition(domain)
    domain.translate_score_1_definition.present? || domain.translate_score_2_definition.present? ||
    domain.translate_score_3_definition.present? || domain.translate_score_4_definition.present?
  end

  def score_definition(definition, score)
    definition.present? ? simple_format(definition) : score
  end

  def get_domains(cd)
    if params[:custom] == 'true'
      cd.object.domain_group.custom_domain_identities
    else
      cd.object.domain_group.default_domain_identities
    end
  end

  def completed_initial_assessment?(type)
    return true if eval("@client.assessments.#{type}.count") == 0
    eval("@client.assessments.#{type}.order(created_at: :asc).first.completed")
  end

  def domain_translation_header(ad)
    if I18n.locale == :km && !ad.domain.custom_domain
      text = ad.domain.local_description[/<strong>.*<\/strong>/].gsub(/<strong>|<\/strong>/, '')
      domain_number = text[/[^\(.*]*/]
      domain_name   = text[/\(.*/]

      content_tag(:nil) do
        content_tag(:td, content_tag(:b, "#{domain_number}:"), class: "no-padding-bottom") + content_tag(:td, content_tag(:b, domain_name), class: "no-padding-bottom")
      end
    else
      content_tag(:td, content_tag(:b, "#{I18n.t('.domains.domain_list.domains')} #{ad.domain.name}:"), class: "no-padding-bottom") + content_tag(:td, content_tag(:b, ad.domain.identity), class: "no-padding-bottom")
    end
  end

  def assess_header_mapping(default=true)
    domains = default ? Domain.csi_domains.map{ |domain| ["domain_#{domain.id}", domain.name] } : Domain.custom_csi_domains.map{ |domain| ["domain_#{domain.id}", domain.name] }
    domain_ids, domain_headers = domains.map(&:first), domains.map(&:last)
    assessment_headers = [t('.client_id'), t('.client_name'), t('.assessment_number'), t('.assessment_date')]

    assessment_domain_headers = ['slug', 'name', 'assessment-number', 'date']
    classNames = ['client-id', 'client-name', 'ssessment-number text-center', 'assessment-date', 'assessment-score text-center']

    [*assessment_domain_headers, *domain_ids].zip(classNames, [*assessment_headers, *domain_headers]).map do |field_header, class_name, header_name|
      { title: header_name, data: field_header, className: class_name ? class_name : 'assessment-score text-center' }
    end
  end

  def map_assessment_and_score(object, identity, domain_id)
    if $param_rules.nil?
      assessments = object.assessments.defaults.joins(:assessment_domains)
    else
      basic_rules = $param_rules['basic_rules']
      basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
      query_string = get_assessment_query_string(results, identity, domain_id, object.id)

      assessments = object.assessments.joins(:assessment_domains).where(query_string).distinct
      serivce_query_string = get_assessment_query_string([results[0].reject{|arr| arr[:field] != identity }], identity, domain_id, object.id)
    end
    assessment_domains = assessments.map{|assessment| assessment.assessment_domains.where(serivce_query_string.reject(&:blank?).join(" AND ")) }.flatten.uniq
  end

  def mapping_assessment_query_rules(data, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_assessment_query_rules(h, field_name=nil, data_mapping)
      end
      if field_name.nil?
       next if !(h[:id] =~ /^(domainscore|assessment_completed|assessment_number|month_number|date_nearest)/i)
      else
       next if h[:id] != field_name
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def get_assessment_query_string(results, identity, domain_id, client_id=nil)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        if h[:field] == 'assessment_completed'
          date_of_assessments_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input], domain_id)
        elsif h[:field] == identity
          assessment_score_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input], domain_id)
        elsif h[:field] == 'assessment_number'
          "(SELECT COUNT(*) FROM assessments WHERE assessments.client_id = #{client_id ? client_id : 'clients.id'}) >= #{h[:value]}"
        elsif h[:field] == 'month_number'
          beginning_of_month = "SELECT DATE(date_trunc('month', created_at)) FROM assessments WHERE assessments.client_id = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{h[:value]} - 1"
          end_of_month = "SELECT (date_trunc('month', created_at) +  interval '1 month' - interval '1 day')::date FROM assessments WHERE assessments.client_id = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{h[:value]} - 1"
          "DATE(assessments.created_at) between (#{beginning_of_month}) AND (#{end_of_month})"
        elsif h[:field] == 'assessment_has_changed'
          # limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          "assessment_domains.domain_id = #{domain_id} and assessment_domains.previous_score != assessment_domains.score WHERE assessments.client_id = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT #{@value.last.to_i - (@value.first.to_i - 1)} OFFSET #{@value.first.to_i - 1}"
        elsif h[:field] == 'assessment_has_not_changed'

        elsif h[:field] == 'month_has_changed'
        elsif h[:field] == 'month_has_not_changed'

        elsif h[:field] == 'date_nearest'
          "date(assessments.created_at) <= '#{h[:value]}'"
        end
      end.join(" #{condition} ")
    end
  end

  def date_of_assessments_query_string(id, field, operator, value, type, input_type, domain_id)
    case operator
    when 'equal'
      "date(assessments.created_at) = #{value.to_date}"
    when 'not_equal'
      "date(assessments.created_at) != #{value.to_date} OR assessments.created_at IS NULL"
    when 'less'
      "date(assessments.created_at) < #{value.to_date}"
    when 'less_or_equal'
      "date(assessments.created_at) <= #{value.to_date}"
    when 'greater'
      "date(assessments.created_at) > #{value.to_date}"
    when 'greater_or_equal'
      "date(assessments.created_at) >= #{value.to_date}"
    when 'between'
      "(date(assessments.created_at) BETWEEN '#{value[0].to_date}' AND '#{value[1].to_date}')"
    when 'is_empty'
      "assessments.created_at IS NULL"
    when 'is_not_empty'
      "assessments.created_at IS NOT NULL"
    end
  end

  def assessment_score_query_string(id, field, operator, value, type, input_type, domain_id)
    case operator
    when 'equal'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score = #{value}"
    when 'not_equal'
      "assessment_domains.domain_id != #{domain_id} AND assessment_domains.score != #{value} OR assessment_domains.domain_id IS NULL"
    when 'less'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score < #{value}"
    when 'less_or_equal'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score <= #{value}"
    when 'greater'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score > #{value}"
    when 'greater_or_equal'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score >= #{value}"
    when 'between'
      "assessment_domains.domain_id = #{domain_id} AND assessment_domains.score IN (#{value.first..value.last})"
    when 'is_empty'
      "assessment_domains.domain_id IS NULL OR assessment_domains.score IS NULL"
    when 'is_not_empty'
      "assessment_domains.domain_id IS NOT NULL OR assessment_domains.score IS NOT NULL"
    end
  end
end
