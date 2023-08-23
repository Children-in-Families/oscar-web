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

  def by_age_translation(developmental_marker_name)
    developmental_marker_name = '1 year' if developmental_marker_name.match(/12 months/)
    developmental_marker_name = '1.5 years' if developmental_marker_name.match(/18 months/)
    developmental_marker_name = developmental_marker_name.downcase.gsub(" ", "_").gsub(".", "_")

    t("inline_help.cb_dmat.by_age_#{developmental_marker_name}").html_safe
  end
end
