class CaseWorkerClientOffline
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "case_worker_clients", database: "history_database"
  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :tenant, type: String, default: ->{ Organization.current.short_name }
  field :object, type: Hash

  embeds_many :assessments
  embeds_many :case_notes
  embeds_many :tasks
  embeds_many :client_enrollments
  embeds_many :custom_formable

  def self.initial
    binding.pry
    Mongoid.raise_not_found_error = false
    case_worker = CaseWorker.find_by(case_worker_id: current_user.id)

    if case_worker.present?
      case_worker_attribute = {"name" => "test", "date_of_birth" => "20-02-1998", "gender" => "female"}
      case_worker.update_attributes = case_worker_attribute
    else
      case_worker_attribute = {"name" => "test", "date_of_birth" => "20-02-1998", "gender" => "female"}
      create(object: case_worker_attribute, case_worker_id: 1)
    end
  end
end