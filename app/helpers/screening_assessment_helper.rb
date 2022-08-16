module ScreeningAssessmentHelper
  def field_to_local(object, field_name)
    if I18n.locale == :km
      object.public_send("#{field_name}_local")
    else
      object.public_send(field_name)
    end
  end

  def date_of_birth_in_words(date_of_birth, locale = :en)
    if date_of_birth.present?
      age_hash = age_in_hash(date_of_birth)
      age_in_words = time_ago_in_words(date_of_birth, include_seconds: false, locale: locale)
      age_in_words.gsub(/,\s\d+\s(hour(s)?.*|ម៉ោង.*)/, '')
    else
      "No Date of Birth"
    end
  end
end
