module PerPageFormHelper
  def url_per_page(controller_name, value)
    show_per_page = {
      client:           client_version_path(value),
      family:           family_version_path(value),
      partner:          partner_version_path(value),
      user:             user_version_path(value),
      agency:           agency_version_path(value),
      department:       department_version_path(value),
      domain:           domain_version_path(value),
      domain_group:     domain_group_version_path(value),
      province:         province_version_path(value),
      referral_source:  referral_source_version_path(value),
      quantitive_type:  quantitative_type_version_path(value),
      quantitive_case:  quantitative_case_version_path(value),
      intervention:     intervention_version_path(value),
      location:         location_version_path(value),
      material:         material_version_path(value),
      progress_note:    progress_note_type_version_path(value),
      changelog:        changelog_version_path(value)
    }
    show_per_page[controller_name.downcase.to_sym]
  end
end
