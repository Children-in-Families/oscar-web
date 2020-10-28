class AdvancedSearch < ActiveRecord::Base
  has_paper_trail
  belongs_to :user

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }

  scope :non_of, ->(value) { where.not(user_id: value.id) }
  BROKEN_SAVE_SEARCH = [["demo", 19],["demo", 18],["demo", 39],["mtp", 15],["mtp", 25],["voice", 2],
                        ["cif", 3],["cif", 4],["cif", 5],["cif", 6],["cif", 7],["cif", 66],["cif", 64],
                        ["cif", 68]]
  BROKEN_RULE_MTP   = [41,5,51]
  BROKEN_RULE_DEMO  = [8]

  def search_params
    { client_advanced_search: { custom_form_selected: custom_forms,
                                program_selected: program_streams,
                                enrollment_check: enrollment_check,
                                tracking_check: tracking_check,
                                exit_form_check: exit_form_check,
                                quantitative_check: quantitative_check,
                                hotline_check: hotline_check,
                                action_report_builder: '#builder' }
                                }
  end

  def owner
    user.name
  end
end


