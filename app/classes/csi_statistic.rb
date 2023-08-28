class CsiStatistic
  def initialize(clients)
    @clients = clients
    @@setting = Setting.cache_first
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
        a_domain_score = domain.assessment_domains.select{ |ad| ad.assessment_id.in?(a_ids) }.map(&:score).compact
        assessment_by_value << (a_domain_score.sum.to_f / a_domain_score.size).round(2)
      end
      series << { name: domain.name, data: assessment_by_value }
    end

    [assessments, series]
  end

  def assessment_amount
    data = []
    return data unless @clients && @clients.any?

    clients = @clients.includes(:assessments).where('assessments.client_id IS NOT NULL').order('assessments.created_at')
    assessment_ids = clients.map { |a| a.assessments.map(&:id) }

    max_count = assessment_ids.map { |ids| ids.size }.max.to_i

    max_count.times do |i|
      data << assessment_ids.map { |ids| ids[i] }
    end
    data
  end

  def fetch_default_assessment_domain_score
    assessments_by_index = default_assessment_amount

    assessments = []
    series = []

    default_assessment_amount.size.times { |i| assessments << "Assessment (#{i + 1})" }
    assessment_domains = Hash.new { |h, k| h[k] = [] }

    assessments_by_index.each do |a_ids|
      domain_scores = AssessmentDomain.where(assessment_id: a_ids).pluck(:domain_id, :score)
      domain_scores.each { |domain_id, score| assessment_domains[domain_id.to_s] << score }
    end

    Domain.csi_domains.pluck(:id, :name).each do |id, name|
      series << { name: name, data:  assessment_domains[id.to_s].map(&:to_f) }
    end

    [assessments, series]
  end

  def default_assessment_amount
    data = []
    return data unless @clients && @clients.any?

    clients = @clients.joins(:assessments).where(assessments: { default: true }).order('assessments.created_at')
    assessments_count = Client.maximum('assessments_count')
    client = Client.find_by(assessments_count: assessments_count)
    # assessment_max_count = client.assessments.defaults.count
    data = clients.includes(:assessments).map { |c| c.assessments.defaults.ids }
  end

  def fetch_custom_assessment_domain_score
    assessments = []
    series = []

    custom_assessment_amount.size.times { |i| assessments << "Assessment (#{i + 1})" }

    assessment_domains = Hash.new { |h, k| h[k] = [] }

    domain_data = AssessmentDomain.where(assessment_id: custom_assessment_amount.flatten).pluck(:domain_id, :score)

    custom_assessment_amount.each.with_index do |_a_ids, index|
      domain_scores = domain_data[index]
      domain_scores.each { |domain_id, score| assessment_domains[domain_id.to_s] << score }
    end

    Domain.custom_csi_domains.pluck(:id, :name).each do |id, name|
      series << { name: name, data:  assessment_domains[id.to_s].map(&:to_f) }
    end

    [assessments, series]
  end

  def custom_assessment_amount
    @custom_assessment_amount ||= @clients.includes(:custom_assessments).where('assessments.client_id IS NOT NULL').order('assessments.created_at').map { |c| c.custom_assessments.map(&:id) }
  end
end
