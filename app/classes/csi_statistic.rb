class CsiStatistic
  def initialize(clients)
    @clients = clients
  end

  def assessment_domain_score
    assessments_by_index = assessment_amount

    assessments = []
    series = []

    assessment_amount.size.times { |i| assessments << "Assessment (#{i + 1})" }

    Domain.includes(:assessment_domains).each do |domain|
      assessment_by_value = []

      assessments_by_index.each do |a_ids|
        a_domain_score = domain.assessment_domains.where(assessment_id: a_ids).pluck(:score).compact
        assessment_by_value << (a_domain_score.sum.to_f / a_domain_score.size).round(2)
      end
      series << { name: domain.name, data: assessment_by_value }
    end

    [assessments, series]
  end

  private

  def assessment_amount
    data = []
    return data unless @clients.any?
    clients = @clients.joins(:assessments).order('assessments.created_at')
    max_count = clients.map { |a| a.assessments.size }.max.to_i
    max_count.times do |i|
      data << clients.map { |c| c.assessments[i].id if c.assessments[i].present? }
    end
    data
  end
end
