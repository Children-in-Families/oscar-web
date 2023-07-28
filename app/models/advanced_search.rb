class AdvancedSearch < ActiveRecord::Base
  include CacheHelper
  extend Enumerize

  enumerize :search_for, in: [:client, :family], default: :client, predicates: { prefix: true }

  has_paper_trail
  belongs_to :user

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }

  after_commit :flush_cache

  scope :non_of, ->(value) { where.not(user_id: value.id) }
  BROKEN_SAVE_SEARCH = [["demo", 19],["demo", 18],["demo", 39],["mtp", 15],["mtp", 25],["voice", 2],
                        ["cif", 3],["cif", 4],["cif", 5],["cif", 6],["cif", 7],["cif", 66],["cif", 64],
                        ["cif", 68]]
  BROKEN_RULE_MTP   = [41,5,51]
  BROKEN_RULE_DEMO  = [8]

  scope :for_client, -> { where(search_for: :client) }
  scope :for_family, -> { where(search_for: :family) }

  default_scope { order(:name) }

  def search_params
    { "#{search_for}_advanced_search" => { custom_form_selected: custom_forms,
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

  def self.cached_advanced_search(params_id)
    Rails.cache.fetch([Apartment::Tenant.current, 'AdvancedSearch', params_id]) do
       self.find(params_id)
    end
  end

  private

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'User', user_id, 'advance_saved_search'])
    Rails.cache.delete([Apartment::Tenant.current,  self.class.name, self.id])
    Rails.cache.fetch([Apartment::Tenant.current,  'User', self.user_id, "other_advanced_search_queries"])
  end
end


