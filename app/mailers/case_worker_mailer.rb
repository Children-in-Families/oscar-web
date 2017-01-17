class CaseWorkerMailer < ActionMailer::Base
  
  def tasks_due_tomorrow_of(user)
    @user = user
    mail(to: @user.email, subject: 'Incomplete Tasks Due Tomorrow')
  end
end
