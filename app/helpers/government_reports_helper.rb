module GovernmentReportsHelper
  def checked?(value)
    'checked' if @client.quantitative_cases.pluck(:value).any? { |e| e.include?(value) }
  end
end
