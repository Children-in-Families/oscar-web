module ApplicationHelper
  def date_format(date)
    date.strftime('%d %B %Y') if date.present?
  end
end
