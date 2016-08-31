class ChartScore
  def assessment_domain_score
    data = []
    Domain.all.each do |domain|
      h1 = {}
      h2 = {}
      h1[:name] = domain.name
      a_domain = domain.assessment_domains.group_by {|v| v.created_at.strftime("%B-%Y")}
      a_domain.each do |key, assessment_domains|
        a_domain_score = []
        assessment_domains.each do |assessment_domain|
          a_domain_score.push assessment_domain.score if assessment_domain.domain_id == domain.id
        end
        average_domain_score = (a_domain_score.sum.to_f / a_domain_score.size).round(2)
        h2[key] = average_domain_score
        h1[:data] = h2
      end
      data.push h1
    end
    score_by_domain = data
  end
end