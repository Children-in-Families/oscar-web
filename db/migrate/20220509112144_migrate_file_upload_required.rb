class MigrateFileUploadRequired < ActiveRecord::Migration[5.2]
  def up
    return if Apartment::Tenant.current_tenant == 'shared'

    fields = %w(
      national_id
      passport
      birth_cert
      family_book
      travel_doc
      letter_from_immigration_police
      ngo_partner
      mosavy
      dosavy
      msdhs
      complain
      local_consent
      warrant
      verdict
      screening_interview_form
      short_form_of_ocdm
      short_form_of_mosavy_dosavy
      detail_form_of_mosavy_dosavy
      short_form_of_judicial_police
      police_interview
      other_legal_doc
    )

    FieldSetting.where(klass_name: :client, name: fields).update_all(can_override_required: true)
  end
end
