module AbleScreeningAnswersHelper

  def answerable(from_age, to_age, client_date_of_birth)
    return true if from_age.blank? && to_age.blank?
    !(from_age >= client_date_of_birth && client_date_of_birth >= to_age)
  end

end
