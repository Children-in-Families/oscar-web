class AdvancedSearch < ActiveRecord::Base
  has_paper_trail
  belongs_to :user

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }

  scope :non_of, ->(value) { where.not(user_id: value.id) }

  def search_params
    { client_advanced_search: { custom_form_selected: custom_forms,
                                program_selected: program_streams,
                                enrollment_check: enrollment_check,
                                tracking_check: tracking_check,
                                exit_form_check: exit_form_check,
                                basic_rules: queries.to_json,
                                quantitative_check: quantitative_check }
                                }.merge(field_visible)
  end

  def owner
    user.name
  end
end
