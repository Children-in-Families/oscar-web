class CaseWorkerMailer < ActionMailer::Base
  default from: 'cifdonotreply@gmail.com'

  def tasks_due_tomorrow_of(user)
    @user = user
    mail(to: @user.email, subject: 'Incomplete Tasks Due Tomorrow')
  end
end
