class CsiStatistic
  def initialize(clients)
    @clients = clients
    @@setting = Setting.first
  end

  def assessment_domain_score
    if @@setting.enable_default_assessment? && @@setting.enable_custom_assessment?
      fetch_all_assessment_domain_score
    elsif @@setting.enable_default_assessment?
      fetch_default_assessment_domain_score
    elsif @@setting.enable_custom_assessment?
      fetch_custom_assessment_domain_score
    end
  end

  private

  def fetch_all_assessment_domain_score
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

  def fetch_default_assessment_domain_score
    assessments_by_index = default_assessment_amount

    assessments = []
    series = []

    default_assessment_amount.size.times { |i| assessments << "Assessment (#{i + 1})" }

    Domain.csi_domains.includes(:assessment_domains).each do |domain|
      assessment_by_value = []

      assessments_by_index.each do |a_ids|
        a_domain_score = domain.assessment_domains.where(assessment_id: a_ids).pluck(:score).compact
        assessment_by_value << (a_domain_score.sum.to_f / a_domain_score.size).round(2)
      end
      series << { name: domain.name, data: assessment_by_value }
    end

    [assessments, series]
  end

  def default_assessment_amount
    data = []
    return data unless @clients.any?
    clients = @clients.joins(:assessments).where(assessments: { default: true }).order('assessments.created_at')
    max_count = clients.map { |a| a.assessments.defaults.size }.max.to_i
    max_count.times do |i|
      data << clients.map { |c| c.assessments.defaults[i].id if c.assessments.defaults[i].present? }
    end
    data
  end

  def fetch_custom_assessment_domain_score
    assessments_by_index = custom_assessment_amount

    assessments = []
    series = []

    custom_assessment_amount.size.times { |i| assessments << "Assessment (#{i + 1})" }

    Domain.custom_csi_domains.includes(:assessment_domains).each do |domain|
      assessment_by_value = []

      assessments_by_index.each do |a_ids|
        a_domain_score = domain.assessment_domains.where(assessment_id: a_ids).pluck(:score).compact
        assessment_by_value << (a_domain_score.sum.to_f / a_domain_score.size).round(2)
      end
      series << { name: domain.name, data: assessment_by_value }
    end

    [assessments, series]
  end

  def custom_assessment_amount
    data = []
    return data unless @clients.any?
    clients = @clients.joins(:assessments).where(assessments: { default: false }).order('assessments.created_at')
    max_count = clients.map { |a| a.assessments.customs.size }.max.to_i
    max_count.times do |i|
      data << clients.map { |c| c.assessments.customs[i].id if c.assessments.customs[i].present? }
    end
    data
  end
end
