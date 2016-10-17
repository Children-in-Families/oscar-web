class HomeController < AdminController
  def index
    @dashboard       = Dashboard.new(current_user)
    @overdue_tasks   = Task.incomplete.overdue.of_user(current_user)
    @due_today_tasks = Task.incomplete.today.of_user(current_user)
    assessments      = current_user.assessment_either_overdue_or_due_today
    @overdue_assessments_count   = assessments[0]
    @due_today_assessments_count = assessments[1]
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
