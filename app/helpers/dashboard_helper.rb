module DashboardHelper
  def checkbox_forms
    if params[:assessments].nil? && params[:forms].nil? && params[:tasks].nil?
      'true'
    else
      if params[:forms].presence == 'true'
        'true'
      end
    end
  end

  def checkbox_tasks
    if params[:assessments].nil? && params[:forms].nil? && params[:tasks].nil?
      'true'
    else
      if params[:tasks].presence == 'true'
        'true'
      end
    end
  end

  def checkbox_assessments
    if params[:assessments].nil? && params[:forms].nil? && params[:tasks].nil?
      'true'
    else
      if params[:assessments].presence == 'true'
        'true'
      end
    end
  end

  def skipped_record?(type, client, tasks, forms)
    if type == 'overdue'
      skipped_tasks = tasks.empty?
      skipped_forms = forms[:overdue_forms].empty? && forms[:overdue_trackings].empty?
      skipped_assessments = !(client.next_assessment_date < Date.today)
    elsif type == 'duetoday'
      skipped_tasks = tasks.empty?
      skipped_forms = forms[:today_forms].empty? && forms[:today_trackings].empty?
      skipped_assessments = !(client.next_assessment_date == Date.today)
    elsif type == 'upcoming'
      skipped_tasks = tasks.empty?
      skipped_forms = forms[:upcoming_forms].empty? && forms[:upcoming_trackings].empty?
      skipped_assessments = !(client.next_assessment_date.between?(Date.tomorrow, 3.month.from_now))
    end

    case
    when params[:assessments].presence == 'true' && params[:tasks].presence == 'true' &&  params[:forms].presence == 'true'
      return true if skipped_tasks && skipped_forms && skipped_assessments
    when params[:assessments].presence == 'true' && params[:tasks].presence == 'true'
      return true if skipped_assessments && skipped_tasks
    when params[:assessments].presence == 'true' && params[:forms].presence == 'true'
      return true if skipped_assessments && skipped_forms
    when params[:tasks].presence == 'true' && params[:forms].presence == 'true'
      return true if skipped_tasks && skipped_forms
    when params[:assessments].presence == 'true'
      return true if skipped_assessments
    when params[:tasks].presence == 'true'
      return true if skipped_tasks
    when params[:forms].presence == 'true'
      return true if skipped_forms
    end
  end
end