class GovernmentReportDecorator < Draper::Decorator
  delegate_all

  def initial_date_format
    initial_date.strftime('%d / %m / %Y ') if initial_date
  end

  def client_born_date
    client_date_of_birth.strftime('%d / %m / %Y ') if client_date_of_birth
  end

  def client_initial_referal_day
    client_initial_referral_date.strftime('%d') if client_initial_referral_date
  end

  def client_initial_referal_month
    client_initial_referral_date.strftime('%m') if client_initial_referral_date
  end

  def client_initial_referal_year
    client_initial_referral_date.strftime('%Y') if client_initial_referral_date
  end
end
