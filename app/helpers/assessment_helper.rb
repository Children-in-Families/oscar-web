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

  def order_assessment(assessment)
    assessment_domains = (assessment.persisted? && !assessment.draft?) ? assessment.assessment_domains.includes(:domain) : assessment.assessment_domains

    if assessment_domains.all?{|ad| ad.domain.name[/\d+/]&.to_i }
      assessment_domains.sort_by{ |ad| [ad.domain.name[/\d+/]&.to_i, ad.domain.name, ad.domain_id] }
    else
      assessment_domains.sort_by(&:domain_id)
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
    domain.translate_score_3_definition.present? || domain.translate_score_4_definition.present? ||
    domain.translate_score_5_definition.present? || domain.translate_score_6_definition.present? ||
    domain.translate_score_7_definition.present? || domain.translate_score_8_definition.present? ||
    domain.translate_score_9_definition.present? || domain.translate_score_10_definition.present?
  end

  def score_definition(definition, score)
    definition.present? ? simple_format(definition) : score
  end

  def get_domains(case_note_domain, custom_assessment_setting_id=nil)
    if params[:custom] == 'true'
      if case_note_domain.object.family_id
        case_note_domain.object.domain_group.family_custom_domain_identities
      else
        case_note_domain.object.domain_group.custom_domain_identities(custom_assessment_setting_id)
      end
    else
      case_note_domain.object.domain_group.default_domain_identities(custom_assessment_setting_id)
    end
  end

  def completed_initial_assessment?(type, obj = 'client')
    return true if eval("@#{obj}.assessments.#{type}.count") == 0
    eval("@#{obj}.assessments.#{type}.order(created_at: :asc).first.completed")
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

  def assess_header_mapping
    domains = Domain.cache_order_by_identity.select(&:client_csi?).map{ |domain| ["domain_#{domain.id}", domain.name] }
    domain_ids, domain_headers = domains.map(&:first), domains.map(&:last)

    assessment_headers = [t('.client_id'), t('.client_name'), t('.assessment_number', assessment: t('clients.show.assessment')), t('.assessment_date', assessment: t('clients.show.assessment')), t('.average_score', assessment: t('clients.show.assessment'))]

    assessment_domain_headers = ['slug', 'name', 'assessment-number', 'date', 'average-score']
    classNames = ['client-id', 'client-name', 'assessment-number text-center', 'assessment-date', 'average-score text-center', 'assessment-score text-center']

    [*assessment_domain_headers, *domain_ids].zip(classNames, [*assessment_headers, *domain_headers]).map do |field_header, class_name, header_name|
      { title: header_name, data: field_header, className: class_name ? class_name : 'assessment-score text-center' }
    end
  end

  def custom_assessment_header_mapping
    return @custom_assessment_header_mapping if defined?(@custom_assessment_header_mapping)

    @custom_assessment_header_mapping = {}

    CustomAssessmentSetting.where(enable_custom_assessment: true).includes(:domains).each do |custom_csi_setting|
      domains = custom_csi_setting.domains.map{ |domain| ["domain_#{domain.id}", domain.name] }
      domain_ids, domain_headers = domains.map(&:first), domains.map(&:last)
  
      assessment_headers = [t('.client_id'), t('.client_name'), t('.assessment_number', assessment: t('clients.show.assessment')), t('.assessment_date', assessment: t('clients.show.assessment')), t('.average_score', assessment: t('clients.show.assessment'))]
  
      assessment_domain_headers = ['slug', 'name', 'assessment-number', 'date', 'average-score']
      classNames = ['client-id', 'client-name', 'assessment-number text-center', 'assessment-date', 'average-score text-center', 'assessment-score text-center']
  
      @custom_assessment_header_mapping[custom_csi_setting.id] = [*assessment_domain_headers, *domain_ids].zip(classNames, [*assessment_headers, *domain_headers]).map do |field_header, class_name, header_name|
        { title: header_name, data: field_header, className: class_name ? class_name : 'assessment-score text-center' }
      end
    end

    @custom_assessment_header_mapping
  end

  def family_assessment_header_mapping
    domains = Domain.family_custom_csi_domains.order_by_identity.map{ |domain| ["domain_#{domain.id}", domain.name] }
    domain_ids, domain_headers = domains.map(&:first), domains.map(&:last)

    assessment_headers = [t('families.show.id'), t('families.show.name'), t('client_advanced_searches.custom_assessment_domain_score.assessment_number', assessment: t('clients.show.assessment')), t('client_advanced_searches.custom_assessment_domain_score.assessment_date', assessment: t('clients.show.assessment')), t('client_advanced_searches.custom_assessment_domain_score.average_score', assessment: t('clients.show.assessment'))]

    assessment_domain_headers = ['id', 'name', 'assessment-number', 'date', 'average-score']
    classNames = ['family-id', 'family-name', 'assessment-number text-center', 'assessment-date', 'average-score text-center', 'assessment-score text-center']

    [*assessment_domain_headers, *domain_ids].zip(classNames, [*assessment_headers, *domain_headers]).map do |field_header, class_name, header_name|
      { title: header_name, data: field_header, className: class_name ? class_name : 'assessment-score text-center' }
    end
  end

  def map_assessment_and_score(object, identity, domain_id)
    sub_query_string = []
    if $param_rules.nil?
      assessments = object.assessments.joins(:assessment_domains).distinct
    else
      basic_rules = $param_rules['basic_rules']
      basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_assessment_query_rules(basic_rules, identity).reject(&:blank?)
      assessment_completed_sql, assessment_number = assessment_filter_values(results)

      if results.present?
        assessments = []
        sql = "(assessments.completed = true)".squish
        if assessment_number.present? && assessment_completed_sql.present?
          assessments = object.assessments.where(sql).limit(1).offset(assessment_number - 1).order('created_at')
        elsif assessment_completed_sql.present?
          sql = assessment_completed_sql[/assessments\.created_at.*/]
          assessments = object.assessments.completed.where(sql).order('created_at')
        end

        sub_query_string = get_assessment_query_string("#{object.class.name.downcase}_id", [results[0].reject { |arr| arr[:field] != identity }], identity, domain_id, object.id)
        assessments = assessments.joins(:domains).where(sub_query_string.reject(&:blank?).join(' AND ')).where(domains: { identity: identity })
      else
        rule = basic_rules['rules'].select { |h| h['id'] == 'date_of_assessments' || h['id'] == 'completed_date' }.first

        if rule.present?
          date_of_assessments_query = date_of_assessments_query_string(rule[:id], rule['field'], rule['operator'], rule['value'])
          assessments = object.assessments.where(date_of_assessments_query)
        else
          assessments = object.assessments
        end
        assessments
      end
    end
  end

  def mapping_assessment_query_rules(data, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_assessment_query_rules(h, field_name=nil, data_mapping)
      end
      if field_name.nil?
        next if h[:id] !~ /^(domainscore|assessment_completed|assessment_completed_date|completed_date|assessment_number|month_number|date_nearest)/i
      elsif h[:id] != field_name
        next
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def get_assessment_query_string(object_id_field, results, identity, domain_id, client_id=nil, basic_rules=nil)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        value = h[:value] == 0 ? 1 : h[:value]
        value = value.try(:to_i).present? ? h[:value] : 1

        if h[:field][/assessment_completed|assessment_completed_date|completed_date/]
          date_of_completed_assessments_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input])
        elsif h[:field] == identity && ['assessment_has_changed', 'assessment_has_not_changed', 'month_has_changed', 'month_has_not_changed'].exclude?(h[:operator])
          assessment_score_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input], domain_id)
        elsif h[:field] == 'assessment_number'
          value = h[:value] == 0 ? 1 : h[:value]
          value = value.try(:to_i).present? ? h[:value] : 1

          if basic_rules
            assessment_completed_result = mapping_assessment_query_rules(basic_rules, 'assessment_completed')
            assessment_only_query_string = get_assessment_query_string(object_id_field, assessment_completed_result, identity, domain_id, client_id)
            assessment_completed_date = " #{assessment_only_query_string.first} AND " if assessment_only_query_string.first.present?
          end

          beginning_of_month = "SELECT DATE(date_trunc('month', created_at)) FROM assessments WHERE#{assessment_completed_date || ''} assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{value} - 1"
          end_of_month = "SELECT (date_trunc('month', created_at) +  interval '1 month' - interval '1 day')::date FROM assessments WHERE assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{value} - 1"

          "(DATE(assessments.created_at) between (#{beginning_of_month}) AND (#{end_of_month})) AND (SELECT COUNT(*) FROM assessments WHERE assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'}) >= #{h[:value]}"
        elsif h[:field] == 'month_number'
          value = h[:value] == 0 ? 1 : h[:value]
          value = value.try(:to_i).present? ? h[:value] : 1

          beginning_of_month = "SELECT DATE(date_trunc('month', created_at)) FROM assessments WHERE assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{value} - 1"
          end_of_month = "SELECT (date_trunc('month', created_at) +  interval '1 month' - interval '1 day')::date FROM assessments WHERE assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'} ORDER BY assessments.created_at LIMIT 1 OFFSET #{value} - 1"
          "DATE(assessments.created_at) between (#{beginning_of_month}) AND (#{end_of_month})"
        elsif h[:field] == identity && h[:operator] == 'assessment_has_changed'
          # limit_assessments = client.assessments.order(:created_at).offset(@value.first.to_i - 1).limit(@value.last.to_i - (@value.first.to_i - 1))
          "(SELECT COUNT(*) FROM assessments WHERE (assessment_domains.domain_id = #{domain_id} AND assessment_domains.previous_score = #{h[:value].first} AND assessment_domains.score = #{h[:value].second}) AND assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'}) > 0"
        elsif h[:field] == identity && h[:operator] == 'assessment_has_not_changed'
          "(SELECT COUNT(*) FROM assessments WHERE ((assessment_domains.domain_id = #{domain_id} AND assessment_domains.previous_score = assessment_domains.score) OR (assessment_domains.domain_id = #{domain_id} AND assessment_domains.previous_score = #{h[:value].first} AND assessment_domains.score != #{h[:value].last})) AND assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'}) > 0"
        elsif h[:field] == identity && h[:operator] == 'month_has_changed'
          "(SELECT COUNT(*) FROM assessments WHERE (assessment_domains.domain_id = #{domain_id} AND assessment_domains.previous_score != assessment_domains.score) AND assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'}) > 1"
        elsif h[:field] == identity && h[:operator] == 'month_has_not_changed'
          "(SELECT COUNT(*) FROM assessments WHERE (assessment_domains.domain_id = #{domain_id} AND assessment_domains.previous_score IS NULL OR assessment_domains.previous_score = assessment_domains.score) AND assessments.#{object_id_field} = #{client_id ? client_id : 'clients.id'}) > 1"
        elsif h[:field] == 'date_nearest'
          "date(assessments.created_at) <= '#{h[:value]}'"
        end
      end.reject(&:blank?).join(" #{condition} ")
    end
  end

  def date_of_assessments_query_string(id, field, operator, value)
    case operator
    when 'equal'
      "date(assessments.created_at) = '#{value.to_date}'"
    when 'not_equal'
      "date(assessments.created_at) != '#{value.to_date}' OR assessments.created_at IS NULL"
    when 'less'
      "date(assessments.created_at) < '#{value.to_date}'"
    when 'less_or_equal'
      "date(assessments.created_at) <= '#{value.to_date}'"
    when 'greater'
      "date(assessments.created_at) > '#{value.to_date}'"
    when 'greater_or_equal'
      "date(assessments.created_at) >= '#{value.to_date}'"
    when 'between'
      "(date(assessments.created_at) BETWEEN '#{value[0].to_date}' AND '#{value[1].to_date}')"
    when 'is_empty'
      "assessments.created_at IS NULL"
    when 'is_not_empty'
      "assessments.created_at IS NOT NULL"
    end
  end

  def date_of_completed_assessments_query_string(id, field, operator, value, type, input_type)
    case operator
    when 'equal'
      "assessments.completed = true AND date(assessments.completed_date) = '#{value.to_date}'"
    when 'not_equal'
      "assessments.completed = true AND date(assessments.completed_date) != '#{value.to_date}' OR assessments.completed_date IS NULL"
    when 'less'
      "assessments.completed = true AND date(assessments.completed_date) < '#{value.to_date}'"
    when 'less_or_equal'
      "assessments.completed = true AND date(assessments.completed_date) <= '#{value.to_date}'"
    when 'greater'
      "assessments.completed = true AND date(assessments.completed_date) > '#{value.to_date}'"
    when 'greater_or_equal'
      "assessments.completed = true AND date(assessments.completed_date) >= '#{value.to_date}'"
    when 'between'
      "assessments.completed = true AND (date(assessments.completed_date) BETWEEN '#{value[0].to_date}' AND '#{value[1].to_date}')"
    when 'is_empty'
      "assessments.completed = true AND assessments.completed_date IS NULL"
    when 'is_not_empty'
      "assessments.completed = true AND assessments.completed_date IS NOT NULL"
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

  def assessment_filter_values(results)
    assessment_number = nil
    date_1, date_2 = nil, nil
    assessment_completed_sql = ''
    results.map do |result|
      condition = ''
      result.map do |h|
        if h[:id] == 'assessment_completed'
          values = h[:value]
          date_1, date_2 = values.first, values.last
          assessment_completed_sql = "AND assessments.created_at BETWEEN '#{date_1}' AND '#{date_2}'"
        elsif h[:id] == 'assessment_number'
          assessment_number = h[:value]
        end
      end
    end
    [assessment_completed_sql, assessment_number]
  end

  def domain_name_translate(assessment, domain)
    if assessment.default && assessment.client_id?
      t("domains.domain_names.#{domain.name.downcase.reverse}")
    else
      domain.name
    end
  end

  def domain_name_for_aht(ad, index = 0)
    if I18n.locale == :km
      if Organization.ratanak?
        domain_header = ad.domain.local_description.scan(/\<strong\>.*\<\/strong\>/)[0]
      else
        domain_header = ad.domain.local_description.scan(/\p{Khmer}|[[:space:]]/).join.squish
      end

      content_tag(:nil) do
        content_tag(:td, content_tag(:b, domain_header.gsub(' ៖', '៖').html_safe), class: "no-padding-bottom")
      end
    else
      content_tag(:nil) do
        domain_identity = t("dimensions.dimensions_identies.#{ad.domain.identity}")[/translation_missing/] ? ad.domain.identity : t("dimensions.dimensions_identies.#{ad.domain.identity}")
        content_tag(:td, content_tag(:b, "#{t('dimensions.dimension_list.dimensions')}: "), class: "no-padding-bottom") + content_tag(:td, content_tag(:b, domain_identity, class: "no-padding-bottom"))
      end
    end
  end

  def find_custom_assessment_setting
    CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def any_family_domain?
    Domain.where(domain_type: 'family').any?
  end

  def check_assessment_domain_exist?(assessment)
    if assessment.assessment_domains.first.blank? || assessment.assessment_domains.first.domain.custom_assessment_setting.blank?
      "(#{t('domains.index.csi_tool')})"
    elsif assessment.assessment_domains.first.domain
      "#{assessment.assessment_domains.first.domain.custom_assessment_setting&.custom_assessment_name}"
    end
  end

  def calculate_domain_selected_domain_score(assessment)
    sum = assessment.assessment_domains.inject(0) do |sum, ad|
      sum + (current_setting.selected_domain_ids.compact.include?(ad.domain_id) && ad.score.present? ? ad.score : 0)
    end

    return sum if sum.zero?

    (sum.to_f / current_setting.selected_domain_ids.compact.size).round
  end

  def check_setting_assessment_type_name_selected(assessment)
    setting_assessment_type_id = Setting.cache_first.assessment_type_name
    
    if assessment.default
      true
    elsif assessment.custom_assessment_setting.blank?
      false
    else
      return assessment.object.custom_assessment_setting.id.to_s == setting_assessment_type_id if assessment.instance_of?(::AssessmentDecorator)
      assessment.custom_assessment_setting.id.to_s == setting_assessment_type_id
    end
  end
end
