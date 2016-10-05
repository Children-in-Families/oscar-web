class CsiStatistic

  def initialize(clients)
    @clients = clients
  end

  def assessment_domain_score
    assessments_by_index = assessment_amount
    data = []
    Domain.all.each do |domain|
      h1 = {}
      h2 = {}
      h1[:name] = domain.name
      i = 1
      assessments_by_index.each do |a_ids|
        ad_by_assessment_index = domain.assessment_domains.where(assessment_id: a_ids)
        a_domain_score = ad_by_assessment_index.pluck(:score)
        average_domain_score = (a_domain_score.sum.to_f / a_domain_score.size).round(2)
        h2[:"Assessment (#{i})"] = average_domain_score
        i += 1
      end
      h1[:data] = h2
      data << h1
    end
    score_by_domain = data
  end
  
  private
  def assessment_amount
    data = []
    if @clients.present?
      max_count = @clients.map(&:assessments).map(&:count).max
      max_count.times do |i|
        arr = []
        @clients.each do |c|
          c.assessments.to_a.at(i).blank? ? arr << nil : arr << c.assessments.to_a.at(i).id
        end
        data << arr.select(&:present?)
      end
    end
    data
  end
end
