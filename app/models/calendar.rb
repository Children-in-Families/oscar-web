class Calendar < ActiveRecord::Base
  belongs_to :user

  scope :sync_status_false, -> { where(sync_status: false) }

  def self.populate_tasks(task)
    task_name  = task.name
    domain     = Domain.find(task.domain_id)
    title      = "#{domain.name} - #{task_name}"
    start_date = task.completion_date
    end_date   = (start_date + 1.day).to_s

    create(title: title, start_date: start_date, end_date: end_date, user_id: task.user_id)
  end

  def self.update_tasks(calendars, task_params)
    task_name  = task_params[:name]
    domain     = Domain.find(task_params[:domain_id])
    title      = "#{domain.name} - #{task_name}"
    start_date = task_params[:completion_date]
    end_date   = (start_date.to_date + 1.day).to_s
    calendars.each do |calendar|
      calendar.update(title: title, start_date: start_date, end_date: end_date, sync_status: false)
    end
  end
end
